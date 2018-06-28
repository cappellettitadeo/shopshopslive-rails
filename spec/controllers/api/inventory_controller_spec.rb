require 'rails_helper'

describe Api::InventoryController, :vcr, type: :controller do
  before do
    @api_key = ApiKey.generate_key
    request.headers["Authorization"] = @api_key.auth_token
  end

  describe 'GET #query' do
    before do
      @ctr_prod_id = '234442'
      @ctr_sku_id = '11333'
      @product = create(:product, ctr_product_id: @ctr_prod_id)
      @variant = create(:product_variant, product: @product, ctr_sku_id: @ctr_sku_id)
      @params = {
        prod_id: @ctr_prod_id,
        sku_id: @ctr_sku_id
      }
    end

    it 'should return the product if it exists' do
      get 'query', params: @params

      res = JSON.parse response.body
      expect(res['prod_id']).to eq(@ctr_prod_id)
      expect(res['sku_id']).to eq(@ctr_sku_id)
      expect(res['inventory']).to eq(@variant.inventory)
      expect(res['vendor']).to eq(@product.vendor_id)
    end

    it 'should return 400 if product can not be found' do
      @params[:prod_id] = '111'
      get 'query', params: @params

      res = JSON.parse response.body
      expect(response.code).to eq('400')
      expect(res['em']).to match('Could not find this prod_id')
    end

    it 'should return 400 if sku can not be found' do
      @params[:sku_id] = '111'
      get 'query', params: @params

      res = JSON.parse response.body
      expect(response.code).to eq('400')
      expect(res['em']).to match('Could not find this sku_id')
    end
  end
end
