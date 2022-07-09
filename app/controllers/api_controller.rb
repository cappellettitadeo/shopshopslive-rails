class ApiController < ActionController::API
  before_action :set_headers
  before_action :authenticate_request

  private

  def set_headers
    @headers = request.headers
  end

  def authenticate_request
    @api_key = api_key

    render json: { error: 'Not Authorized' }, status: 401 unless @api_key
  end

  def api_key
    @api_key ||= ApiKey.find_by_key(decoded_auth_token[:api_key]) if decoded_auth_token
    puts '@api_key'
    puts @api_key
    @api_key || errors.add(:token, 'Invalid token') && nil
  end

  def decoded_auth_token
    @decoded_auth_token ||= JsonWebToken.decode(http_auth_header)

    @decoded_auth_token
  end

  def http_auth_header
    if @headers['Authorization'].present?
      return @headers['Authorization'].split(' ').last
    else
      errors.add(:token, 'Missing token')
    end
    nil
  end
end
