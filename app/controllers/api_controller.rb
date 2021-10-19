class ApiController < ActionController::API
  before_action :authenticate_request

  private

  def authenticate_request
    @api_key = AuthorizeApiRequest.call(request.headers).result
    render json: { error: 'Not Authorized' }, status: 401 unless @api_key
  end
end
