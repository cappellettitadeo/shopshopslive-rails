class Api::ApiKeysController < ApiController
  skip_before_action :authenticate_request
  swagger_controller :api_keys, "ApiKeys管理"

  swagger_api :login do
    summary "Login to get authentication token"
    param :query, :name, :string, :required, "Username: shopshops"
    param :query, :pwd, :string, :required, "Password: Shopshops2018"
  end

  def login
    key = ApiKey.find_by_name(params[:name])
    if key && key.valid_password?(params[:pwd])
      render json: { data: { token: key.auth_token } }, status: :ok
    else
      render json: { ec: 401, em: 'Not Authorized' }, status: 401
    end
  end

  # For testing purposes only
  def trigger_callback
    ProductsSyncWorker.perform_async
    render json: { msg: 'success' }, status: :ok
  end

  # For testing purposes only
  def trigger_inventory_callback
    # id 47 is the Blur-Dating store product variant
    InventorySyncWorker.perform_async(47)
    render json: { msg: 'success' }, status: :ok
  end
end
