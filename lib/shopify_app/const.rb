module ShopifyApp
  class Const
    API_KEY ||= ENV['SHOPIFY_API_KEY']
    API_SECRET ||= ENV['SHOPIFY_API_SECRET']
    BASE_URL ||= ENV['BASE_URL']
    APP_URL ||= "#{BASE_URL}/shopify_app"
    #SCOPE ||= %w(read_product_listings write_draft_orders write_products write_customers write_orders write_inventory write_shipping write_checkouts unauthenticated_write_checkouts unauthenticated_write_customers read_shopify_payments_payouts)
    SCOPE ||= %w(read_product_listings read_products write_customers read_shipping write_checkouts write_orders write_draft_orders write_fulfillments)
    CUSTOMER_INFO ||= {
      first_name: 'ShopShops',
      last_name: 'Sales'
    }
    #TODO Email needs to be set by shopshops
    ACCOUNT_EMAIL ||= 'liyiawu@shopshops.com.cn'
    EVENTS_TOPICS ||= {
        :product_listings => %w(add remove update),
        :draft_orders => %w(create update),
        :fulfillments => %w(create update),
        :orders => %w(create updated cancelled fulfilled paid partially_fulfilled),
        :products => %w(create update delete),
        :refunds => %w(create),
        :shop => %w(update),
        :app => %w(uninstalled)}
    USER_AGENT ||= 'Mozilla\/5.0 with ShopShops'
    SERVER_DEPLOY_IP ||= '52.4.95.228'
  end
end
