require 'shopify_app'

class ShopifyWebhooksWorker
  include Sidekiq::Worker

  sidekiq_options unique: true

  def perform(store_id = nil)
    if store_id
      store = Store.find(store_id)
      ShopifyApp::Utils.instantiate_session(store.source_url, store.source_token)
      ShopifyApp::Utils.create_webhooks
    end
  end
end
