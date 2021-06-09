class Api::InventoryController < ApiController
  before_action :find_resource

  def query
    hash = {
      prod_id: params[:prod_id],
      sku_id: params[:sku_id],
      inventory: @variant.inventory,
      vendor_id: @product.vendor_id
    }
    render json: { data: hash }, status: :ok
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
        vendor_id: @product.vendor_id
      }
      render json: { data: hash }, status: :ok
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
