class ApiKey < ApplicationRecord
  after_create :set_auth_token

  def self.generate_key
    hashid = Hashids.new(ENV["SLUG_SALT"], 25, "abcdefghijklmnopqrstuvwxyz1234567890")
    key = hashid.encode(Time.now)
    create key: key
  end

  def set_auth_token
    exp = Time.now.to_i + 3600 * 24 * 365 * 100
    self.auth_token = JsonWebToken.encode({ api_key: key, exp: exp })
    self.expires_at = Time.at exp
    self.save
  end
end
