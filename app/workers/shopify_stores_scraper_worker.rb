class ShopifyStoresScraperWorker
  include Sidekiq::Worker

  sidekiq_options unique: true

  def perform(store_id = nil)
    scraper = Scrapers::Shopify::Scraper.new
    if store_id
      store = Store.find store_id
      scraper.parse(store)
    else
      # 1. Get all active stores that use shopify
      #stores = Store.active.shopify
      # 2. Fetch products from each store
      #stores.each do |store|
      #  scraper.parse(store)
      #end
    end
    #update expired product's availability to false
    expired_products = Product.where('expires_at < ?', DateTime.now)
    if expired_products.present?
      expired_products.each do |expired_product|
        expired_product.update(available: false)
      end
    end
  end
end
