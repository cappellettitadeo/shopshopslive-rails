class Api::ApiKeysController < ApiController
  skip_before_action :authenticate_request
  swagger_controller :api_keys, "ApiKeys管理"

  swagger_api :login do
    summary "Login to get authentication token"
    param :query, :name, :string, :required, "Username"
    param :query, :pwd, :string, :required, "Password"
  end

  def login
    key = ApiKey.find_by_name(params[:name])
    if key && key.valid_password?(params[:pwd])
      render json: { token: key.auth_token }, status: :ok
    else
      render json: { ec: 401, em: 'Not Authorized' }, status: 401
    end
  end
end

