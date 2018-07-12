class VendorSerializer
  include FastJsonapi::ObjectSerializer

  attributes :id, :ctr_vendor_id, :name, :name_en, :description, :logo_url
end
