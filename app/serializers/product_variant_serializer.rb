class ProductVariantSerializer
  include FastJsonapi::ObjectSerializer

  attributes :name, :color, :currency_info, :size, :count, :barcode
end
