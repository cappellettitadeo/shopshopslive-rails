module ShopifyApp
  class Const
    API_KEY = ENV['API_KEY']
    API_SECRET = ENV['API_SECRET']
    BASE_URL = ENV['BASE_UTL']
    APP_URL = ENV['APP_URL']
    SCOPE = %w(read_product_listings write_checkouts write_draft_orders)
    EVENTS_TOPICS = {
        :product_listings => %w(add remove update),
        :shop => %w(update),
        :app => %w(uninstalled)}
  end
end