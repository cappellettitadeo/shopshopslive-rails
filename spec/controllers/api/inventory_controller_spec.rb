require 'rails_helper'

describe Api::InventoryController, :vcr, type: :controller do
  before do
    @api_key = ApiKey.generate_key("shopshops")
    request.headers["Authorization"] = @api_key.auth_token
    @ctr_prod_id = '234442'
    @ctr_sku_id = '11333'
    @store = create(:store, source_url: "shopsshopsla.myshopify.com",  source_token: "4d3f074be79beeda98d5e4b8fb256a83")
    @product = create(:product, store: @store, ctr_product_id: @ctr_prod_id, source_id: "1087668256825")
    @product.sync_with_shopify
    @variant = @product.product_variants.first
    @variant.update(ctr_sku_id: @ctr_sku_id)
    @params = {
      prod_id: @ctr_prod_id,
      sku_id: @ctr_sku_id
    }
  end

  describe 'GET #query' do
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

  describe 'GET #lock' do
    before do
      @params[:locked_count] = 2
    end

    it 'should return 200 if product has enough inventory' do
      get 'lock', params: @params

      res = JSON.parse response.body
      expect(response.code).to eq('200')
      expect(res['data']['prod_id']).to eq(@ctr_prod_id)
      expect(res['data']['sku_id']).to eq(@ctr_sku_id)
      expect(res['data']['vendor_id']).to eq(@product.reload.vendor_id)
      expect(res['data']['inventory']).to eq(@variant.reload.inventory)
      expect(res['data']['locked_inventory']).to eq(@params[:locked_count])
    end

    it 'should return 400 if product does not have enough inventory' do
      @params[:locked_count] = 1000
      original_inventory = @variant.reload.inventory
      get 'lock', params: @params

      res = JSON.parse response.body
      expect(response.code).to eq('400')
      expect(res['em']).to match('Not enough inventory')
      expect(@variant.reload.inventory).to eq(original_inventory)
    end

    it 'should return 400 if product can not be found' do
      @params[:prod_id] = '1111'
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
