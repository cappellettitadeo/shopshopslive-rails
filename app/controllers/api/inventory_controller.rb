class Api::InventoryController < ApiController
  before_action :find_resource

  swagger_controller :inventory, "库存管理"

  swagger_api :query do
    summary "查询商品库存信息"
    param :header, 'Authorization', :string, :required, '当前用户Auth token'
    param :query, :prod_id, :string, :required, "中心系统商品ID"
    param :query, :sku_id, :string, :required, "中心系统商品sku id"

    response :bad_request
    response :ok
  end

  def query
    hash = {
      prod_id: params[:prod_id],
      sku_id: params[:sku_id],
      inventory: @variant.inventory,
      vendor: @product.vendor_id
    }
    render json: hash, status: :ok
  end

  swagger_api :lock do
    summary "查询商品库存信息"
    param :header, 'Authorization', :string, :required, '当前用户Auth token'
    param :query, :prod_id, :string, :required, "中心系统商品ID"
    param :query, :sku_id, :string, :required, "中心系统商品sku id"
    param :query, :locked_count, :string, :required, "锁定商品数量"

    response :bad_request
    response :ok
  end

  def lock
    lock_count = params[:locked_count].to_i
    success = @variant.lock_inventory(lock_count)
    if success
      hash = {
        prod_id: params[:prod_id],
        sku_id: params[:sku_id],
        inventory: @variant.inventory,
        locked_inventory: lock_count,
        vendor: @product.vendor_id
      }
      render json: hash, status: :ok
    else
      render json: { ec: 400, em: 'Not enough inventory' }, status: :bad_request
    end
  end

  private

  def find_resource
    ctr_product_id = params[:prod_id]
    ctr_sku_id = params[:sku_id]
    @product = Product.find_by_ctr_product_id ctr_product_id
    if @product
      @variant = @product.product_variants.where(ctr_sku_id: ctr_sku_id).first
      render json: { ec: 400, em: 'Could not find this sku_id' }, status: :bad_request unless @variant
    else
      render json: { ec: 400, em: 'Could not find this prod_id' }, status: :bad_request
    end
  end
end
