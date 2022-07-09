class ApiController < ActionController::API
  before_action :authenticate_request

  private

  def authenticate_request
    headers = request.headers
    puts "---- headers: #{headers} -----"
    authorization_headers = headers['Authorization']
    puts "---- athorization_headers: #{authorization_headers} -----"

    @api_key = AuthorizeApiRequest.call(authorization_headers).result
    render json: { error: 'Not Authorized' }, status: 401 unless @api_key
  end
end
