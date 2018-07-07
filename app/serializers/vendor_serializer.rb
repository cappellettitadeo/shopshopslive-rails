class VendorSerializer
  include FastJsonapi::ObjectSerializer

  attributes :id, :ctr_vendor_id, :name, :description, :logo_url

  attribute :name_en do |vendor|
    vendor.name
  end
end
