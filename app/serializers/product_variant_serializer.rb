class ProductVariantSerializer
  include FastJsonapi::ObjectSerializer

  attributes :id, :ctr_sku_id, :source_sku, :name, :currency_info, :count, :barcode, :source_id, :available, :image_id

  attributes :options do |pv|
    arr = []
    pv.options.each do |o|
      arr << { name: o.name, value: o.value }
    end
    arr
  end
end
