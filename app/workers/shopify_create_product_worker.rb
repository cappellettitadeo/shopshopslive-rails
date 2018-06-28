class ShopifyCreateProductWorker
  include Sidekiq::Worker

  def perform(store, product, scraper)
    product_result = Scrapers::Shopify::Result.new(store, product, scraper)
    Product.create_from_shopify_object(store, product_result)
  rescue => err
    Rails.logger.warn "LISTING ERROR: #{err.inspect}"
    Rails.logger.warn err.backtrace.join("\n")
  end
end
