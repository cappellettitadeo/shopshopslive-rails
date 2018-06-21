class Api::InventoryController < ApiController
  respond_to :json

  def query
    ### 参数列表：
    # prod_id - 商品ID
    # sku_id - 同一个商品的不同sku对应的ID
    ctr_product_id = params[:prod_id]
    ctr_sku_id = params[:sku_id]
    prod = Product.find_by_ctr_product_id ctr_product_id
    if prod
      variant = prod.product_variants.where(ctr_sku_id: ctr_sku_id).first
      if variant
        hash = {
          prod_id: params[:prod_id],
          sku_id: params[:sku_id],
          inventory: variant.inventory,
          vendor: prod.vendor_id
        }
        render json: hash, status: :ok
      else
        render json: { ec: 400, em: 'Could not find this sku_id' }, status: :bad_request
      end
    else
      render json: { ec: 400, em: 'Could not find this prod_id' }, status: :bad_request
    end
  end
end

