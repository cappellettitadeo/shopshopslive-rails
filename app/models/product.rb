class Product < ApplicationRecord
	has_many :photos, as: :target, dependent: :destroy
	has_many :product_variants, dependent: :destroy
  has_and_belongs_to_many :categories
  belongs_to :store
  belongs_to :vendor
  belongs_to :scraper

  def self.create_from_shopify_object(store, object)
    #save object to DB
    product = Product.new description: object.description, keywords: object.keywords, material: object.material,
                          name: object.name, store_id: object.store_id, source_id: object.source_id, scraper_id: object.scraper_id,
                          vendor_id: object.vendor_id
    if product.save
      #save all product variants to db
      if object.variants.present?
        object.variants.each do |variant|
          product_variant = ProductVariant.new product: product, barcode: variant.barcode, color: variant.color,
                                               currency: variant.currency, inventory: variant.inventory, name: variant.name,
                                               original_price: variant.original_price, product_id: product.id,
                                               price: variant.price, source_id: variant.source_id, source_sku: variant.source_sku,
                                               size_id: variant.size_id, weight: variant.weight, weight_unit: variant.weight_unit
          product_variant.save
        end
      end
      #save all product photos to db
      if object.photos.present?
        object.photos.each do |photo|
          Photo.compose(product, 'product', photo.src, photo.width, photo.height, photo.position)
        end
      end
    end
  end

  def brandName
    vendor.name if vendor
  end

  def category_1st
    categories.level_1.first
  end

  def category_1st_name
    cat_1 = category_1st
    cat_1.name if cat_1
  end

  def category_1st_id
    cat_1 = category_1st
    cat_1.id if cat_1
  end

  def category_2nd
    categories.level_2.first
  end

  def category_2nd_name
    cat_2 = category_2nd
    cat_2.name if cat_2
  end

  def category_2nd_id
    cat_2 = category_2nd
    cat_2.id if cat_2
  end

  def ctr_vendor_id
    vendor.ctr_vendor_id if vendor
  end
end
