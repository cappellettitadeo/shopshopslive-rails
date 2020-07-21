class UserSerializer
  include FastJsonapi::ObjectSerializer

  attributes :id, :full_name, :first_name, :last_name, :email, :phone, :gender

  attribute :shipping_addresses do |u|
    ShippingAddressSerializer.new(u.shipping_addresses).serializable_hash
  end
end
