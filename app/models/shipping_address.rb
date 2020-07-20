class ShippingAddress < ApplicationRecord
  belongs_to :user
  has_many :orders, -> { order 'created_at DESC' }

  validates_presence_of :full_name, :phone, :address1, :city, :province, :country

  def address
    [country, province, city, address1].compact.join('')
  end

  def address_with_name
    address + " #{name} #{phone}"
  end
end
