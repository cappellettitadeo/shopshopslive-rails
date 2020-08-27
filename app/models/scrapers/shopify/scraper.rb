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
      begin
        products = ShopifyAPI::Product.find(:all, params: { limit: 250 })
      rescue => e
        # Need to ask the store to re-auth
        if e.message.match('403')
          products = ShopifyAPI::ProductListing.find(:all, params: { limit: 250 })
          process_products(store, products, scraper)
          return
        elsif e.message.match('403')
          return
        end
      end
      process_products(store, products, scraper)
      while products.present? && products.next_page?
        products = products.fetch_next_page
        process_products(store, products, scraper)
      end
    end
  end

  def process_products(store, products, scraper)
    if products.present?
      # Call worker to create products
      products.each do |product|
        ShopifyCreateProductWorker.new.perform(store, product, scraper)
      end
    end
  end
end
