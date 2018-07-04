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
      if product.tags.present?
        #convert a comma separated string into an array
        @keywords = product.tags.split(/\s*,\s*/)
      end
    end
    @keywords
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
        @photos = product.images
      end
    end
    @photos
  end

  def store_id
    @store_id ||= store.id
  end

  def source_id
    @source_id ||= product.id
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
        vendor = Vendor.where(name: product.vendor).first_or_create
        @vendor_id = vendor.id
      end
    end
    @vendor_id
  end
end
