class ProductVariantSerializer
  include FastJsonapi::ObjectSerializer

  attributes :id, :ctr_sku_id, :source_sku, :name, :color, :currency_info, :sizes, :count, :barcode, :source_id, :available

  attributes :options do |pv|
    arr = []
    pv.options.each do |o|
      next if ['color', 'size'].include?(o.name.downcase)
      arr << { name: o.name, value: o.value }
    end
    arr
  end
end
