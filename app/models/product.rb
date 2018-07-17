require 'central_app'

class Product < ApplicationRecord
  has_many :photos, as: :target, dependent: :destroy
  has_many :product_variants, dependent: :destroy
  has_many :sync_queues, as: :target, dependent: :destroy
  has_and_belongs_to_many :categories
  belongs_to :store
  belongs_to :vendor
  belongs_to :scraper

  scope :active, -> { where('expires_at > ? AND available IS TRUE', Time.now) }

  audited

  SCRAPED_PRODUCT_EXPIRATION = 3.days

  def self.create_or_update_from_shopify_object(object)
    # changed is a flag to indicate whether the product or it's associations has been changed
    # and need to be synced with the central system
    changed = false

    product = Product.where(source_id: object.source_id).first_or_initialize
    # 1. Save product to DB
    product.name = object.name
    product.description = object.description
    product.keywords = object.keywords
    product.material = object.material
    product.store_id = object.store_id
    product.vendor_id = object.vendor_id
    product.source_id = object.source_id
    product.available = true

    # 1.1 Check if any field has changed when product already exists in DB
    changed = true if product.changed?

    if product.new_record?
      # 1.2 If it's new record, setup expires_at
      product.expires_at = DateTime.now + SCRAPED_PRODUCT_EXPIRATION
      product.relisted_at = DateTime.now
    elsif (DateTime.now + 1.day) > product.expires_at
      # if it's an existing record, renew the product if it's set to expire in the next day
      product.renew
    end


    if product.save
      # 2. Save category to DB
      category = nil
      if product.categories.level_1.blank? && object.keywords.present?
        object.keywords.each do |keyword|
          # Following line assumes we have all ctr categories in our db and we don't need to query central app
          #category = Category.most_alike_by_name_en(keyword)

          # Assume central app returns only one category
          ctr_category = CentralApp::Utils::Category.query("#{keyword}")
          category = Category.create_update_from_ctr_category(ctr_category)
          break if category
        end
        category.products << product if category
      end

      # 2.1 Save sub-category to DB
      if product.categories.level_2.blank? && product.categories.level_1.present? && object.keywords.present?
        category =  product.categories.level_1.first
        sub_category = Category.most_alike_by_name_en(object.keywords.join(',').downcase, 2, category.id)
        sub_category.products << product if sub_category
      end

      # 3. Save all product variants to DB
      if object.variants.present?
        variant_ids = product.product_variants.collect(&:source_id)
        object.variants.each do |variant|
          variant_ids.delete(variant.source_id.to_s) if variant_ids.present?
          variant_updated = ProductVariant.create_or_update_from_shopify_object(product, variant)
          # 3.1 Set changed to true if any variant has been updated
          changed = true if variant_updated
        end
        if variant_ids.present?
          # 3.2 to make sure a variant is still available on Shopify, if the given product does not contain a variant
          # we have in db, then it was already been removed. Marked it as unavailable
          variant_ids.each do |variant_id|
            ProductVariant.find_by_source_id(variant_id).update(available: false)
          end
        end
      end

      # 4. Save all product photos to DB
      if object.photos.present?
        object.photos.each do |photo|
          photo_updated = Photo.compose(product, 'product', photo.src, photo.width, photo.height, photo.position)
          # 4.1 Set changed to true if any photo has been updated
          changed = true if photo_updated
        end
      end
    end
    [product, changed]
  end

	def renew
    self.expires_at = DateTime.now + SCRAPED_PRODUCT_EXPIRATION
    self.relisted_at = DateTime.now
    self.delisted_at = nil
	end

  def sync_with_shopify
    shop_domain = store.source_url
    access_token = store.source_token
    ShopifyApp::Utils.instantiate_session(shop_domain, access_token)
    #update product and variant
    product_listing = ShopifyAPI::ProductListing.find(source_id)
    ShopifyCreateProductWorker.new.perform(store, product_listing, nil)
  end

  def brand_name
    vendor.name_en if vendor
  end

  def category_1st
    categories.level_1.first
  end

  def category_1st_name
    cat_1 = category_1st
    cat_1.name_en if cat_1
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
    cat_2.name_en if cat_2
  end

  def category_2nd_id
    cat_2 = category_2nd
    cat_2.id if cat_2
  end

  def ctr_vendor_id
    vendor.ctr_vendor_id if vendor
  end

  def store_name
    store.name if store
  end

  def store_domain
    store.source_url if store
  end
end
