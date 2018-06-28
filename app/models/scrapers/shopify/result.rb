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
    if @variants.nil?
      @variants = []
      variants = product.variants
      if variants.present?
        variants.each do |variant|
          @variants.push(Scrapers::Shopify::ResultVariant.new(store, product, variant))
        end
      end
    end
    @variants
  end

  def photos
    # TODO
    #@photos = product[:images]
  end
end
