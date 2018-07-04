module ShopifyApp
  class Const
    API_KEY = ENV['API_KEY']
    API_SECRET = ENV['API_SECRET']
    BASE_URL = ENV['BASE_UTL']
    APP_URL = ENV['APP_URL']
    SCOPE = %w(read_orders read_products read_inventory)
    EVENTS_TOPICS = {
        :products => %w(create delete update),
        :shop => %w(update),
        :app => %w(uninstalled)}
  end
end