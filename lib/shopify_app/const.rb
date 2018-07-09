module ShopifyApp
  class Const
    API_KEY = ENV['SHOPIFY_API_KEY']
    API_SECRET = ENV['SHOPIFY_API_SECRET']
    BASE_URL = ENV['BASE_URL']
    APP_URL = "#{BASE_URL}/shopify_app"
    SCOPE = %w(read_product_listings write_draft_orders)
    EVENTS_TOPICS = {
        :product_listings => %w(add remove update),
        :shop => %w(update),
        :app => %w(uninstalled)}
  end
end
