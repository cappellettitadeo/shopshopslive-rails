class VendorSerializer
  include FastJsonapi::ObjectSerializer

  attributes :name, :description
end
