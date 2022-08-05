Rails.application.config.middleware.use OmniAuth::Builder do
# frozen_string_literal: true

provider :shopify,
  ENV['SHOPIFY_API_KEY'],
  ENV['SHOPIFY_API_SECRET'],
  scope: "read_product_listings,read_products,write_customers,read_shipping,write_checkouts,write_orders,write_draft_orders,write_fulfillments",
  setup: lambda { |env|
    strategy = env['omniauth.strategy']

    shop = if strategy.request.params['shop']
      "https://#{strategy.request.params['shop']}"
    else
      ''
    end

    env['omniauth.strategy'].options[:client_options][:site] = shop
  }
end
