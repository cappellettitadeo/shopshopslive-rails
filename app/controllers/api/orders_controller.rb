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
    if params[:order][:user_id].present?
      user = User.find_by_id params[:order][:user_id]
      if user
        # 1. Create an order
        order = Order.create user_id: params[:order][:user_id]
        # 2. Check if it's a draft order
        if params[:order][:status] == 'draft'
          order.status = 'submitted'
          order.draft = true
          order.save
        end
        # 3. Update the address
        if params[:order][:shipping_address_id]
          address = user.shipping_addresses.where(id: params[:order][:shipping_address_id]).first
        elsif params[:order][:shipping_address]
          address = user.shipping_addresses.create(shipping_address_params)
        end
        if address.id
          order.update_attributes(shipping_address_id: address.id)
        else
          render json: { ec: 404, em: address.errors.full_messages[0] }, status: :not_found and return
        end
        # 4. Create line items
        if params[:order][:line_items].present?
          items = params[:order][:line_items]
          store_ids = []
          items.each do |li|
            pv = ProductVariant.where(ctr_sku_id: li[:variant_id]).first
            if pv
              item = LineItem.create(order_id: order.id, product_id: pv.product_id, product_variant_id: pv.id,
                                      quantity: li[:quantity], name: pv.name, price: pv.price, color: pv.color, size_id: pv.size_id)
              s_id = pv.product.store_id
              # Check if all items are from 1 store or multiple stores
              if store_ids.empty?
                store_ids << s_id
                order.store_id = s_id
                order.save
              elsif !store_ids.include?(s_id)
                # If the store id is not in the store_ids, it means this items is from another store
                # Then create a suborder
                store_ids << s_id
                s_order = Order.create(master_order_id: order.id, order_type: 1, store_id: s_id)
                item.update_attributes(suborder_id: s_order.id)
              end
            end
          end
          # If store_ids is > 1, it means there are multiple stores
          # Create a suborder for the first line item
          if store_ids.size > 1
            Order.create(master_order_id: order.id, order_type: 1, store_id: store_ids.first)
          end
        else
          render json: { ec: 400, em: "line_items缺失" }, status: :bad_requst and return
        end
        order.save
        # 5. Generate order with shopify
        begin
          order.generate_order_with_shopify
        rescue => e
          render json: { ec: 400, em: e.message }, status: :bad_request and return
        end
        hash = OrderSerializer.new(order).serializable_hash
        render json: hash, status: :ok
      else
        render json: { ec: 404, em: "无法找到该用户" }, status: :not_found and return
      end
    else
      render json: { ec: 400, em: "user_id缺失" }, status: :bad_request
    end
  end

  def confirm_payment
    order = Order.find_by_id params[:id]
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
    order = Order.find_by_id params[:id]
    if order
      # TODO Need to know what fields can be updated
      order.update_attributes(order_params)
      hash = OrderSerializer.new(order).serializable_hash
      render json: hash, status: :ok
    else
      render json: { ec: 404, em: "无法找到该订单" }, status: :not_found
    end
  end

  def refund
    order = Order.find_by_id params[:id]
    if order
      if order.refundable?
        # Check if line_item and quantity is right
        ids = []
        items = []
        error = nil
        params[:order][:line_items].each do |li|
          item = order.line_items.where(id: li[:id]).first
          if item.nil?
            error = "无法找到对应line_item. ID: #{li[:id]}"
            break
          elsif item.quantity < li[:quantity]
            error = '退款商品数量大于订单商品数量.ID: #{li[:id]}'
            break
          end
          items << [item, li[:quantity]]
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
        render json: { ec: 400, em: "该订单无法退款, status: #{order.status}" }, status: :bad_request
      end
    else
      render json: { ec: 404, em: "无法找到该订单" }, status: :not_found
    end
  end

  def show
    order = Order.find_by_id params[:id]
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
        puts "Order Topic: #{topic}"
        if topic
          ShopifyApp::Utils.instantiate_session(shop, store.source_token)
          data_object = JSON.parse(data, object_class: OpenStruct)
          WebhookRequest.create(source: 'shopify', res: data_object, domain: shop)
          case topic
          when "app/uninstalled"
            ShopifyApp::Webhook.app_uninstalled(store)
          when "fulfillments/create", "fulfillments/update"
            ShopifyApp::Webhook.fulfill(data_object)
          when "orders/updated"
            ShopifyApp::Webhook.fulfill(data_object)
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
    params.require(:order).permit(:user_id, :line_items, :shipping_address_id, :status, :currency, :shipping_method)
  end

  def line_item_params
    params.require(:line_item).permit(:product_id, :product_variant_id, :quantity)
  end

  def shipping_address_params
    params.require(:order).require(:shipping_address).permit(:address1, :address2, :city, :province, :country, :zip, :first_name, :last_name, :phone)
  end
end
