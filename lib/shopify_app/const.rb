module ShopifyApp
  class Const
    API_KEY = ENV['API_KEY']
    API_SECRET = ENV['API_SECRET']
    BASE_URL = ENV['BASE_UTL']
    APP_URL = ENV['APP_URL']
    #SCOPE = %w(read_product_listings read_orders read_products read_inventory read_checkouts write_checkouts read_orders write_orders read_draft_orders write_draft_orders)
    SCOPE = %w(read_product_listings write_checkouts)
    EVENTS_TOPICS = {
        :products => %w(create delete update),
        :shop => %w(update),
        :app => %w(uninstalled)}
  end
end