class ProductSerializer
  include FastJsonapi::ObjectSerializer

  attributes :id, :ctr_product_id, :name, :brand_name, :description, :keywords,
             :category_1st_name, :category_1st_id, :category_2nd_name, :category_2nd_id,
             :material, :ctr_store_id, :store_name, :store_domain, :source_id, :available,
             :ctr_vendor_id

  attribute :skus do |product|
    variants = product.product_variants
    ProductVariantSerializer.new(variants).serializable_hash[:data]
  end

  attribute :photos do |product|
    images = product.photos
    PhotoSerializer.new(images).serializable_hash[:data]
  end
end
