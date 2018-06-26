class Scrapers::Shopify::Scraper < Scrapers::Scraper
  def parse(store)
    scraper = Scraper.create(source: store.source, source_type: store.source_type, url: store.source_url)
    scraper.save

    # 1. Call shopify API to fetch all products

    # 2. Call worker to create products
    products.each do |product|
      ShopifyCreateProductWorker.new.perform(store, product)
    end
  end
end
