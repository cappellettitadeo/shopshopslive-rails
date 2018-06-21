class ApiKey < ApplicationRecord
  after_create :set_auth_token

  def set_auth_token
    exp = Time.now.to_i + 3600 * 24 * 365 * 100
    self.auth_token = JsonWebToken.encode({ api_key: key, exp: exp })
    self.expires_at = exp
    self.save
  end
end
