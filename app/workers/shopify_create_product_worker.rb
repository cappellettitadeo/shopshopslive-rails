class ShopifyCreateProductWorker
  include Sidekiq::Worker

  def perform(store, product, scraper)
    product_result = Scrapers::Shopify::Result.new(store, product, scraper)
    product, changed = Product.create_or_update_from_shopify_object(store, product_result)
    # Add product to SyncQueue if either product, product_variant, product_photo
    # vendor or store has changed
    SyncQueue.create(target: product) if changed
  rescue => err
    Rails.logger.warn "LISTING ERROR: #{err.inspect}"
    Rails.logger.warn err.backtrace.join("\n")
  end
end
