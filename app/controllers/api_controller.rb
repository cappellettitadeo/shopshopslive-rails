class ApiController < ActionController::API
  before_action :authenticate_request

  private

  def authenticate_request
    request_api_key = headers['Authorization']
    if request_api_key != ENV['CTR_API_KEY']
      render json: { error: 'Not Authorized' }, status: 401
    end
  end
end
