class ShopifyCreateProductWorker
  include Sidekiq::Worker

  def perform(store, product, scraper)
    product_result = Scrapers::Shopify::Result.new(store, product, scraper)
    product, changed = Product.create_or_update_from_shopify_object(product_result)
    puts "Product created, ID: #{product.id}"
    # Add product to SyncQueue if either product, product_variant, product_photo
    # vendor or store has changed
    SyncQueue.where(target_type: 'Product', target_id: product.id).first_or_create if changed
  rescue => err
    Rails.logger.warn "LISTING ERROR: #{err.inspect}"
    Rails.logger.warn err.backtrace.join("\n")
  end
end
