require 'rails_helper'

describe Api::ApiKeysController, :vcr, type: :controller do
  before do
    @username = 'shopshops'
    @password = 'shopshops2018'
    @api_key = ApiKey.generate_key(@username, @password)
  end

  describe 'POST #login' do
    it 'should return an auth token if credentials are correct' do
      post 'login', params: { name: @username, pwd: @password }

      res = JSON.parse response.body
      expect(res['token']).to eq(@api_key.auth_token)
    end

    it 'should return 401 if name are incorrect' do
      post 'login', params: { name: 'username', pwd: @password }

      res = JSON.parse response.body
      expect(response.code).to eq('401')
      expect(res['em']).to match('Not Authorized')
    end

    it 'should return 401 if password are incorrect' do
      post 'login', params: { name: @username, pwd: '123456' }

      res = JSON.parse response.body
      expect(response.code).to eq('401')
      expect(res['em']).to match('Not Authorized')
    end
  end
end
