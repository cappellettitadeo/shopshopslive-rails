class ShippingAddressSerializer
  include FastJsonapi::ObjectSerializer

  attributes :id, :full_name, :first_name, :last_name, :address1, :city, :province, :country, :phone, :zip
end

