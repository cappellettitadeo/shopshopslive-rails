require 'shopify_app'

class Scrapers::Shopify::Scraper < Scrapers::Scraper
  def parse(store)
    scraper = ProductScraper.create(source_type: store.source_type, url: store.source_url)
    scraper.save
    myshopify_domain = store.source_url
    access_token = store.source_token
    if myshopify_domain && access_token
      ShopifyApp::Utils.instantiate_session(myshopify_domain, access_token)
      # Call shopify API to fetch all products
      products = ShopifyAPI::ProductListing.find(:all)
      if products.present?
        # Call worker to create products
        products.each do |product|
          ShopifyCreateProductWorker.new.perform(store, product, scraper)
        end
      end
    end
  end
end
