class Product < ApplicationRecord
  has_many :photos, as: :target, dependent: :destroy
  has_many :product_variants, dependent: :destroy
  has_and_belongs_to_many :categories
  belongs_to :store
  belongs_to :vendor
  belongs_to :scraper

  def self.create_from_shopify_object(store, object)
    if Product.find_by_source_id(object.source_id).nil?
      #save object to DB
      product = Product.new description: object.description, keywords: object.keywords, material: object.material,
                            name: object.name, store_id: object.store_id, source_id: object.source_id, scraper_id: object.scraper_id,
                            vendor_id: object.vendor_id
      if product.save
        # save category to DB
        category = nil
        object.keywords.each do |keyword|
          category = Category.where(name: keyword.downcase, level: 1).first
          break if category
        end
        category.products << product if category

        # save sub-category to DB
        sub_category = nil
        object.keywords.each do |keyword|
          sub_category = Category.where(name: keyword.downcase, level: 2).first
          break if sub_category
        end
        sub_category.products << product if sub_category

        #save all product variants to db
        if object.variants.present?
          object.variants.each do |variant|
            ProductVariant.create_from_shopify_variant(product, variant)
          end
        end
        #save all product photos to db
        if object.photos.present?
          object.photos.each do |photo|
            #TODO shopify photo src
            Photo.compose(product, 'product', photo.src, photo.width, photo.height, photo.position)
          end
        end
      end
      product
    else
      update_from_shopify_product(store, object)
    end
  end


  def self.update_from_shopify_product(store, object)
    product = Product.find_by_source_id(object.source_id)
    if product
      product.name = object.name
      product.description = object.description
      product.keywords = object.keywords
      product.material = object.material
      product.vendor_id = object.vendor_id
      product.save

      if object.variants.present?
        object.variants.each do |variant|
          ProductVariant.update_from_shopify_variant(product, variant)
        end
      end

      if object.photos.present?
        object.photos.each do |photo|
          Photo.update(product, 'product', photo.src, photo.width, photo.height, photo.position)
        end
      end
      product
    else
      create_from_shopify_object(store, object)
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
