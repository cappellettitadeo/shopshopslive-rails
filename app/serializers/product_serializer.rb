class ProductSerializer
  include FastJsonapi::ObjectSerializer

  attributes :id, :ctr_product_id, :name, :brand_name, :description, :keywords,
             :category_1st_name, :category_1st_id, :category_2nd_name, :category_2nd_id,
             :material

  attribute :skus do |product|
    variants = product.product_variants
    ProductVariantSerializer.new(variants).serializable_hash
  end

  attribute :photos do |product|
    images = product.photos
    PhotoSerializer.new(images).serializable_hash
  end
end
