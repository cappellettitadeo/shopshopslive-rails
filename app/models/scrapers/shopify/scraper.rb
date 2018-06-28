require 'shopify_app'

class Scrapers::Shopify::Scraper < Scrapers::Scraper
  def parse(store)
    scraper = Scraper.create(source_type: store.source_type, url: store.source_url)
    scraper.save

    if store.source_type.eql? "shopify"
      myshopify_domain = store.source_url
      access_token = store.source_token

      unless myshopify_domain.nil? || access_token.nil?
        ShopifyApp::Utils.instantiate_session(myshopify_domain, access_token)
        #Call shopify API to fetch all products
        products = ShopifyAPI::Product.find(:all)
        if products.any?
          #Call worker to create products
          products.each do |product|
            ShopifyCreateProductWorker.new.perform(store, product)
          end
        end
      end
    end
  end
end
