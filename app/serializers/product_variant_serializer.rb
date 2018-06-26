class ProductVariantSerializer
  include FastJsonapi::ObjectSerializer

  attributes :name, :color, :currency_info, :sizes, :count, :barcode
end
