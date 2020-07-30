class Api::OrdersController < ApiController
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
          order.status = 'draft'
          order.save
        end
        # 3. Update the address
        address = user.shipping_addresses.where(id: params[:order][:shipping_address_id]).first
        if address
          order.update_attributes(shipping_address_id: params[:order][:shipping_address_id])
        else
          render json: { ec: 404, em: "无法找到ShippingAddress" }, status: :not_found and return
        end
        # 4. Create line items
        if params[:order][:line_items].present?
          items = params[:order][:line_items]
          items.each do |li|
            pv = ProductVariant.where(ctr_sku_id: li[:variant_id]).first
            if pv
              order.line_items.create(product_id: pv.product_id, product_variant_id: pv.id, quantity: li[:quantity], name: pv.name, price: pv.price, color: pv.color, size_id: pv.size_id)
            end
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
      render json: hash, status: :ok
    else
      render json: { ec: 404, em: "无法找到该用户" }, status: :not_found
    end
  end

  def update
    order = Order.find_by_id params[:id]
    if order
      order.update_attributes(order_params)
      hash = OrderSerializer.new(order).serializable_hash
      render json: hash, status: :ok
    else
      render json: { ec: 404, em: "无法找到该用户" }, status: :not_found
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

  private
  def order_params
    params.require(:order).permit(:user_id, :line_items, :shipping_address_id, :status, :currency, :shipping_method)
  end

  def line_item_params
    params.require(:order).permit(:product_id, :product_variant_id, :quantity)
  end
end
