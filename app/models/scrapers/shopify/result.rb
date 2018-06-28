class Scrapers::Shopify::Result < Scrapers::Result
  def initialize(store, product)
    @store = store
    @product = product
  end

  attr_reader :product, :store

  def available
    #TODO
  end

  def created_at
    @created_at ||= product.created_at
  end

  def ctr_product_id
    #TODO
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
    #TODO
  end

  def name
    @name ||= product.title
  end

  def photos
    unless @photos.present?
      if product.images.present?
        @photos = []
        product.images.each do |photo|
          @photos.push(Scrapers::Shopify::ResultPhoto.new(store, product, photo))
        end
      end
    end
    @photos
  end

  def store_id
    @store_id ||= store.id
  end

  def source_id
    @source_id ||= store.source_id
  end

  def scraper_id
    #TODO
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
    #TODO
  end

end
