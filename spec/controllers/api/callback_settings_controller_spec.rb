require 'rails_helper'

describe Api::CallbackSettingsController, :vcr, type: :controller do
  before do
    @api_key = ApiKey.generate_key
    request.headers["Authorization"] = @api_key.auth_token
    @product_setting = {
      callback: 'http://intermodu.shopshops.com.cn/product/create_or_update',
      mode: 'bunch',
      bunchsize: '10'
    }
    @inventory_setting = {
      callback: 'http://intermodu.shopshops.com.cn/inventory/update',
      mode: 'bunch',
      bunchsize: '10'
    }
    @store_setting = {
      callback: 'http://intermodu.shopshops.com.cn/store/create_or_update',
      mode: 'bunch',
      bunchsize: '10'
    }
    @vendor_setting = {
      callback: 'http://intermodu.shopshops.com.cn/vendor/create_or_update',
      mode: 'bunch',
      bunchsize: '10'
    }
  end

  describe 'POST #callback' do
    before do
      @params = {
        product: @product_setting,
        inventory: @inventory_setting,
        store: @store_setting,
        vendor: @vendor_setting
      }
    end

    it 'should return 200 if payload is formatted' do
      post 'callback', params: { settings: @params }

      expect(response.code).to eq('200')
      product_setting = CallbackSetting.product.first
      expect(product_setting.url).to eq(@product_setting[:callback])
      expect(product_setting.mode).to eq(@product_setting[:mode])
      expect(product_setting.bunch_size).to eq(@product_setting[:bunchsize].to_i)
    end

    it 'should return 400 if callback url is missing' do
      @vendor_setting[:callback] = nil
      post 'callback', params: { settings: @params }

      res = JSON.parse response.body
      expect(response.code).to eq('400')
      expect(res['em']).to match('Invalid Callback')
    end
  end
end
