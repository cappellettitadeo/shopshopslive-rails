require 'rails_helper'

describe Api::ProductsController, :vcr, type: :controller do
  before do
    @api_key = ApiKey.generate_key("shopshops_us")
    request.headers["Authorization"] = @api_key.auth_token
    @products = create_list(:product_with_variants, 2, variants_count: 3)
  end

  describe 'GET #query' do
    it 'should return all products' do
      get 'query'

      res = JSON.parse response.body
      expect(response.code).to eq('200')
      expect(res['data'].size).to eq(@products.size)
    end

    it 'should return certain products if id is specified' do
      params = { ids: @products.first.ctr_product_id }
      get 'query', params: params

      res = JSON.parse response.body
      prod = res['data'].first
      expect(res['data'].size).to eq(1)
      expect(prod['name']).to eq(@products.first.name)
    end

    it 'should return certain products if title is specified' do
      params = { title: @products.last.name }
      get 'query', params: params

      res = JSON.parse response.body
      prod = res['data'].first
      expect(res['data'].size).to eq(1)
      expect(prod['name']).to eq(@products.last.name)
    end

    it 'should return certain fields of products if fields are specified' do
      params = { fields: ['name', 'description', 'material'].join(',') }
      get 'query', params: params

      res = JSON.parse response.body
      prod = res['data'].first
      expect(res['data'].size).to eq(@products.size)
      expect(prod).to have_key('name')
      expect(prod).to have_key('description')
      expect(prod).to have_key('material')
    end
  end
end
