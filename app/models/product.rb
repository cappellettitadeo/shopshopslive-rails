class Product < ApplicationRecord
  has_many :photos, as: :target, dependent: :destroy
  has_many :product_variants, dependent: :destroy
  has_many :sync_queues, as: :target, dependent: :destroy
  has_many :sync_logs, as: :target, dependent: :destroy
  has_and_belongs_to_many :categories
  belongs_to :store
  belongs_to :vendor
  belongs_to :scraper

  def self.create_or_update_from_shopify_object(object)
    # changed is a flag to indicate whether the product or it's associations has been changed
    # and need to be synced with the central system
    changed = false

    product = Product.where(source_id: object.source_id).first_or_create
    # 1. Save product to DB
    product.name = object.name
    product.description = object.description
    product.keywords = object.keywords
    product.material = object.material
    product.store_id = object.store_id
    product.vendor_id = object.vendor_id
    product.source_id = object.source_id

    # 1.1 Check if any field has changed when product already exists in DB
    changed = true if product.changed?

    if product.save
      # 2. Save category to DB
      category = nil
      object.keywords.each do |keyword|
        category = Category.where(name: keyword.downcase, level: 1).first
        break if category
      end
      category.products << product if category

      # 2.1 Save sub-category to DB
      sub_category = nil
      object.keywords.each do |keyword|
        sub_category = Category.where(name: keyword.downcase, level: 2).first
        break if sub_category
      end
      sub_category.products << product if sub_category

      # 3. Save all product variants to DB
      if object.variants.present?
        object.variants.each do |variant|
          variant_updated = ProductVariant.create_or_update_from_shopify_object(product, variant)
          # 3.1 Set changed to true if any variant has been updated
          changed = true if changed.nil? && variant_updated
        end
      end

      # 4. Save all product photos to DB
      if object.photos.present?
        object.photos.each do |photo|
          #TODO shopify photo src
          photo_updated = Photo.compose(product, 'product', photo.src, photo.width, photo.height, photo.position)
          # 4.1 Set changed to true if any photo has been updated
          changed = true if changed.nil? && photo_updated
        end
      end
    end
    [product, changed]
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
