class Scrapers::Shopify::Result < Scrapers::Result
  def initialize(store, product)
    @store = store
    @product = product
  end

  attr_reader :product, :store

  def description
    #body_html prop of shopify product: a description of the product
    @description ||= product.body_html
  end

  def keywords

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

  def photos
    unless @photos.present?
      if product.images.present?
        @photos = []
        product.images.each do |image|
          @photos.push(Scrapers::Shopify::ResultPhoto.new(store, product, variant))
        end
      end
    end
    @photos
  end
end
