class Api::OrdersController < ApiController
  skip_before_action :authenticate_request, only: [:shopify_webhook]
  before_action :check_variants, only: [:create]

  def index
    page = params[:page] || 1
    if Order::STATUS.include?(params[:status])
      orders = Order.where(status: params[:status]).page(page)
      count = orders.total_count
      json = OrderSerializer.new(orders).serializable_hash[:data]
      render json: { data: json, count: count, current_page: page }, status: :ok
    else
      render json: { ec: 400, em: "Invalid Status" }, status: :bad_request
    end
  end

  def create
    if params[:order][:user].present?
      # 1. Find/Create a user
      user = User.find_by_ctr_user_id params[:order][:user][:ctr_user_id]
      if user
        user.update_attributes(user_params)
      else
        user = User.new(user_params)
      end
      if user.save
        # 1. Create an order
        order = Order.create!(user: user)
        # 2. Check if it's a draft order
        if params[:order][:status] == 'draft'
          order.status = 'submitted'
          order.draft = true
          order.ctr_order_id = params[:order][:ctr_order_id] if params[:order][:ctr_order_id]
          order.save
        end
        # 3. Update the address
        if params[:order][:shipping_address]
          address = user.shipping_addresses.where(shipping_address_params).first_or_create
        end
        if address.id
          order.update_attributes(shipping_address_id: address.id)
        else
          render json: { ec: 404, em: address.errors.full_messages[0] }, status: :not_found and return
        end
        # 4. Create line items
        if params[:order][:line_items].present?
          items = params[:order][:line_items]
          skus = []
          # Check if all items are from 1 store or multiple stores
          items.each { |i| skus << i[:ctr_sku_id] }
          store_ids = ProductVariant.joins(:product).where(ctr_sku_id: skus).pluck(:store_id).uniq
          items.each do |li|
            pv = ProductVariant.where(ctr_sku_id: li[:ctr_sku_id]).first
            if pv
              # 1. Create a line item for the master order
              item = LineItem.create(order_id: order.id, product_id: pv.product_id, product_variant_id: pv.id,
                                      quantity: li[:quantity], name: pv.name, price: pv.price, color: pv.color, size_id: pv.size_id)
              s_id = pv.product.store_id
              # 2. If it has multple stores create suborder
              s_order = nil
              if store_ids.size > 1
                s_order = Order.where(master_order_id: order.id, order_type: 1, store_id: s_id, status: 'submitted', draft: true).first_or_create
                item.update_attributes(suborder_id: s_order.id)
              else
                s_order = order
              end
              if li[:note].present?
                if s_order.note.present?
                  s_order.note = s_order.note.to_s + ';' + li[:note]
                  s_order.save
                else
                  s_order.note = li[:note]
                  s_order.save
                end
              end
            end
          end
          if store_ids.size == 1
            order.update_attributes(store_id: store_ids.first)
          end
        else
          render json: { ec: 400, em: "line_items缺失" }, status: :bad_requst and return
        end
        order.save
        # 5. Generate order with shopify
        #begin
        order.generate_order_with_shopify
        #rescue => e
        #  render json: { ec: 400, em: e.message }, status: :bad_request and return
        #end
        hash = OrderSerializer.new(order).serializable_hash
        render json: hash, status: :ok
      else
        render json: { ec: 400, em: user.errors.full_messages[0] }, status: :not_found and return
      end
    else
      render json: { ec: 400, em: "user缺失" }, status: :bad_request
    end
  end

  def confirm_payment
    order = Order.find_by_source_id params[:id]
    order = Order.find_by_id params[:id] if order.nil?
    if order
      if order.status != 'submitted'
        render json: { ec: 400, em: "订单无法被完成，status: #{order.status}" }, status: :bad_request
      else
        begin
          order.complete
        rescue => e
          render json: { ec: 400, em: e.message }, status: :bad_request and return
        end
        hash = OrderSerializer.new(order).serializable_hash
        render json: hash, status: :ok
      end
    else
      render json: { ec: 404, em: "无法找到该订单" }, status: :not_found
    end
  end

  def update
    order = Order.find_by_source_id(params[:id]) || Order.find_by_id(params[:id])
    if order
      # Update the address
      if params[:order][:shipping_address]
        user = order.user
        address = user.shipping_addresses.where(shipping_address_params).first_or_create
        if address.id
          order.update_attributes(shipping_address_id: address.id)
        else
          render json: { ec: 404, em: address.errors.full_messages[0] }, status: :not_found and return
        end
      end
      order.update_attributes(ctr_order_id: params[:order][:ctr_order_id]) if params[:order][:ctr_order_id]
      #order.update_attributes(note: params[:order][:note]) if params[:order][:note]
      items = params[:order][:line_items]
      items.each do |item|
        li = order.line_items.joins(:product_variant).where("product_variants.ctr_sku_id = ?", item[:ctr_sku_id]).first
        if li
          li.update_attributes(quantity: item[:quantity])
        end
      end
      order.save
      if order.suborders.present?
        orders = order.suborders
        orders.each do |o|
          update_order(o, params)
        end
      else
        update_order(order, params)
      end
      hash = OrderSerializer.new(order.reload).serializable_hash
      render json: hash, status: :ok
    else
      render json: { ec: 404, em: "无法找到该订单" }, status: :not_found
    end
  end

  def refund
    order = Order.find_by_source_id params[:id]
    if order
      if order.refundable?
        # Check if line_item and quantity is right
        ids = []
        items = []
        error = nil
        params[:order][:line_items].each do |item|
          li = order.line_items.joins(:product_variant).where("product_variants.ctr_sku_id = ?", item[:ctr_sku_id]).first
          if li
            li.update_attributes(quantity: item[:quantity])
          elsif li.quantity < item[:quantity]
            render json: { ec: 400, em: "退款商品数量大于订单商品数量，ctr_sku_id: #{item[:ctr_sku_id]}" }, status: :bad_request and return
          else
            render json: { ec: 404, em: "无法找到该line_item，ctr_sku_id: #{item[:ctr_sku_id]}" }, status: :not_found and return
          end
          items << [item, item[:quantity]]
        end
        if error
          render json: { ec: 400, em: error }, status: :bad_request and return
        end
        begin
          order.refund(items)
        rescue => e
          render json: { ec: 400, em: e.message }, status: :bad_request and return
        end
        hash = OrderSerializer.new(order).serializable_hash
        render json: hash, status: :ok
      else
        render json: { ec: 400, em: "该订单未支付，无法退款, 当前订单状态: #{order.status}" }, status: :bad_request
      end
    else
      render json: { ec: 404, em: "无法找到该订单" }, status: :not_found
    end
  end

  def show
    order = Order.find_by_source_id params[:id]
    if order
      hash = OrderSerializer.new(order).serializable_hash
      render json: hash, status: :ok
    else
      render json: { ec: 404, em: '无法找到该订单' }, status: :not_found
    end
  end

  def shopify_webhook
    # inspect hmac value in header and verify webhook
    hmac = request.env['HTTP_X_SHOPIFY_HMAC_SHA256']

    request.body.rewind
    data = request.body.read

    if ShopifyApp::Utils.webhook_ok?(hmac, data)
      shop = request.env['HTTP_X_SHOPIFY_SHOP_DOMAIN']
      store = Store.find_by(source_url: shop)

      if store&.source_token
        topic = request.env['HTTP_X_SHOPIFY_TOPIC']
        logger.warn "Order Topic: #{topic}"
        if topic
          ShopifyApp::Utils.instantiate_session(shop, store.source_token)
          data_object = JSON.parse(data, object_class: OpenStruct)
          WebhookRequest.create(source: 'shopify', res: data_object, domain: shop, topic: topic)
          case topic
          when "app/uninstalled"
            ShopifyApp::Webhook.app_uninstalled(store)
          when "fulfillments/create", "fulfillments/update"
            ShopifyApp::Webhook.fulfill(data_object, 'fulfillment')
          #when "orders/updated"
            #ShopifyApp::Webhook.fulfill(data_object, 'order')
          when "shop/update"
            ShopifyApp::Webhook.shop_update(data_object)
          when "product_listings/add", "product_listings/update"
            ShopifyApp::Webhook.product_listings_add_or_update(store, data_object)
          when "product_listings/remove"
            ShopifyApp::Webhook.product_listings_remove(data_object)
          else
            logger.warn "topic handler not found"
          end
        else
          logger.warn "header does not include topic"
          render json: {ec: 400, em: "topic not provided"}, status: :bad_request and return
        end
        render json: {msg: 'Webhook notification received successfully.'}, status: :ok and return
      end
    end
    render json: {ec: 403, em: "You're not authorized to perform this action."}, status: :forbidden
  end

  def update_order(order, params)
    if params[:order][:line_items]
      items = params[:order][:line_items]
      # set order.note to nil first
      order.note = nil
      items.each do |item|
        li = order.line_items.joins(:product_variant).where("product_variants.ctr_sku_id = ?", item[:ctr_sku_id]).first
        if li
          # If order match this line_item, update note
          if item[:note].present?
            if order.note.present?
              order.note = order.note.to_s + ';' + item[:note]
              order.save
            else
              order.note = item[:note]
              order.save
            end
          end
          li.update_attributes(quantity: item[:quantity])
        end
      end
    end
    # Update shopify
    order.update_order_with_shopify
  end

  private
  def check_variants
    if params[:order][:line_items].present?
      items = params[:order][:line_items]
      items.each do |li|
        pv = ProductVariant.where(ctr_sku_id: li[:ctr_sku_id]).first
        if pv.nil? || pv.product.nil? || pv.product.store.nil?
          render json: { ec: 404, em: "无法找到ctr_sku_id: #{li[:ctr_sku_id]}" }, status: :not_found and return
        elsif pv.inventory < li[:quantity]
          render json: { ec: 400, em: "库存不足, ctr_sku_id: #{li[:ctr_sku_id]}" }, status: :bad_request and return
        end
      end
    end
  end
  
  def order_params
    params.require(:order).permit(:ctr_order_id, :user_id, :shipping_address_id, :status, :currency, :shipping_method, :draft, :note)
  end

  def user_params
    params.require(:order).require(:user).permit(:first_name, :last_name, :phone, :full_name, :gender, :email, :ctr_user_id)
  end

  def line_item_params
    params.require(:line_items).permit(:product_id, :ctr_sku_id, :quantity)
  end

  def shipping_address_params
    params.require(:order).require(:shipping_address).permit(:address1, :address2, :city, :province, :country, :zip, :first_name, :last_name, :phone)
  end
end
