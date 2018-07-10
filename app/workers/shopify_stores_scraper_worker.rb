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
      stores = Store.active.shopify
      # 2. Fetch products from each store
      stores.each do |store|
        scraper.parse(store)
      end
    end
  end
end
