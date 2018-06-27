require 'shopify_app'

class Scrapers::Shopify::Scraper < Scrapers::Scraper
  def parse(store)
    scraper = Scraper.create(source: store.source, source_type: store.source_type, url: store.source_url)
    scraper.save

    # 1. Call shopify API to fetch all products
    if store.source_type.equal? 'shopify'
      myshopify_domain = store.source_url
      access_token = store.source_token
      unless myshopify_domain.nil? && access_token.nil?
        ShopifyApp::Utils.instantiate_session(myshopify_domain, access_token)
        products = ShopifyAPI::Product.find(:all)
        if products.any?
          # 2. Call worker to create products
          products.each do |product|
            ShopifyCreateProductWorker.new.perform(store, product)
          end
        end
      end
    end
  end
end
