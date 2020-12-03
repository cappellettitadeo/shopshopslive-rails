class AuthorizeApiRequest
  prepend SimpleCommand

  def initialize(headers = {})
    @headers = headers
  end

  def call
    api_key
  end

  private

  attr_reader :headers

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
    puts headers['Authorization']
    if headers['Authorization'].present?
      return headers['Authorization'].split(' ').last
    else
      errors.add(:token, 'Missing token')
    end
    nil
  end
end
