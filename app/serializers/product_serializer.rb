class ProductSerializer
  include FastJsonapi::ObjectSerializer

  attributes :name, :brandName, :description, :keywords,
             :category_1st, :category_1st_id, :category_2nd, :category_2nd_id,
             :material

  attribute :skus do |product|
    variants = product.product_variants
    ProductVariantSerializer.new(variants).serializable_hash
  end

  attribute :images do |product|
    images = product.photos
    PhotoSerializer.new(images).serializable_hash
  end
end
