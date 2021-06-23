
class User < ApplicationRecord

  has_many :shipping_addresses, -> { order 'created_at DESC' }
  has_many :orders, -> { order 'created_at DESC' }

  before_save :set_full_name
  after_create :set_slug
  after_commit :update_shopify_customer, if: proc { |user| user.previous_changes.present?  }

  def default_shipping_address
    shipping_addresses.where(default_address: true).first
  end

  def set_full_name
    if full_name.nil? && first_name && last_name
      self.full_name = "#{first_name} #{last_name}"
    end
  end

  def set_slug
    chars = "abcdefghijklmnopqrstuvwxyz1234567890"
    hashids = Hashids.new(ENV["SLUG_SALT"], 16, chars)
    self.slug = hashids.encode(id)
    self.save
  end

  def set_auth_token
    # 创建一个新的auth token
    exp = Time.now.to_i + 3600 * 24 * 365 * 100
    self.authentication_token = JsonWebToken.encode({ user_id: id, exp: exp })
    self.save
  end

  def email_required?
    false
  end

  def password_required?
    false
  end

  def created_at_formatted
    created_at.strftime("%Y-%m-%d %H:%M:%S")
  end

  def updated_at_formatted
    updated_at.strftime("%Y-%m-%d %H:%M:%S")
  end

  def update_shopify_customer
    if source_id
      # Update existing shopify customer
    else
      # Create a new shopify customer
      res = ShopifyApp::Order.create_customer(self)
    end
  end
end
