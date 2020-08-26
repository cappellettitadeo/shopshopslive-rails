class ShippingAddress < ApplicationRecord
  belongs_to :user
  has_many :orders, -> { order 'created_at DESC' }

  validates_presence_of :phone, :address1, :city, :province, :country

  before_validation :check_input

  def address
    [country, province, city, address1].compact.join('')
  end

  def address_with_name
    address + " #{full_name} #{phone}"
  end

  def check_input
    if first_name.nil?
      self.first_name = user.first_name
    end
    if last_name.nil?
      self.last_name = user.last_name
    end
    if full_name.nil?
      self.full_name = "#{user.first_name} #{user.last_name}"
    end
    if phone.nil?
      self.phone = user.phone
    end
    if country == '中国'
      self.country = 'CN'
    end
  end
end
