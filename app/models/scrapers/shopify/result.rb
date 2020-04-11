require 'central_app'

class Scrapers::Shopify::Result < Scrapers::Result
  def initialize(store, product, scraper)
    @store = store
    @product = product
    @scraper = scraper
  end

  attr_reader :product, :store, :scraper

  def available
    #default
  end

  def created_at
    @created_at ||= product.created_at
  end

  def ctr_product_id
    #not the concern so far
  end

  def description
    #body_html prop of shopify product: a description of the product
    @description ||= product.body_html
  end

  def keywords
    unless @keywords.present?
      @keywords = []
      @keywords.prepend(product.product_type) unless product.product_type.blank?
      if product.tags.present?
        #convert a comma separated string into an array
        tags = product.tags.split(/\s*,\s*/)
        @keywords.concat(tags)
      end
    end
    @keywords if @keywords.present?
  end

  def product_type
    product.product_type
  end

  def material
    unless @material.present?
      product.options.each do |option|
        return @material = option.values.join(", ") if option.name.downcase == "material"
      end
    end
    @material
  end

  def name
    @name ||= product.title
  end

  def photos
    unless @photos.present?
      if product.images.present?
        new_images = []
        product.images.each do |item|
          item.is_cover = 0
          # if product.image.present? && item.id == product.image.id
          #   item.is_cover = 1
          # end
          new_images.push(item)
        end
        @photos = new_images
      end
    end
    @photos
  end

  def store_id
    @store_id ||= store.id
  end

  def source_id
    unless @source_id
      if product.product_id
        @source_id = product.product_id
      else
        @source_id = product.id if product.id
      end
    end
    @source_id
  end

  def scraper_id
    @scraper_id ||= scraper && scraper.id
  end

  def updated_at
    @updated_at ||= product.updated_at
  end

  def variants
    unless @variants.present?
      if product.variants.present?
        @variants = []
        product.variants.each do |variant|
          @variants.push(Scrapers::Shopify::ResultVariant.new(store, product, variant))
        end
      end
    end
    @variants
  end

  def vendor_id
    unless @vendor_id
      if product.vendor
        vendor = Vendor.where(name_en: product.vendor).first
        if vendor
          unless vendor.ctr_vendor_id
            ctr_vendors = CentralApp::Utils::Vendor.query(vendor.name_en)
            if ctr_vendors.present?
              ctr_vendors.each do |ctr_vendor|
                if ctr_vendor[:name_en] == vendor.name_en
                  vendor.update_from_ctr_vendor(ctr_vendor)
                  break
                end
              end
            end
          end
        else
          ctr_vendors = CentralApp::Utils::Vendor.query(product.vendor)
          if ctr_vendors.present?
            ctr_vendors.each do |ctr_vendor|
              if ctr_vendor[:name_en] == product.vendor
                vendor = Vendor.create_or_update_from_ctr_vendor(ctr_vendor)
                break
              end
            end
          end
          vendor = Vendor.create(name_en: product.vendor) unless vendor
        end
        @vendor_id = vendor.id if vendor
      end
    end
    @vendor_id
  end
end
