class ProductVariantSerializer
  include FastJsonapi::ObjectSerializer

  attributes :id, :ctr_sku_id, :source_sku, :name, :color, :currency_info, :sizes, :count, :barcode, :source_id
end
