class ProductVariantSerializer
  include FastJsonapi::ObjectSerializer

  attributes :id, :ctr_sku_id, :name, :color, :currency_info, :sizes, :count, :barcode
end
