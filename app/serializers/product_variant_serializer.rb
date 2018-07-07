class ProductVariantSerializer
  include FastJsonapi::ObjectSerializer

  attributes :id, :ctr_sku_id, :name, :color, :currency_info, :size, :count, :barcode
end
