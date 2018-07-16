require 'httparty'

module ShopifyApp
  class Utils

    class << self

      def valid_request_from_shopify?(request)
        hmac = request.params['hmac']

        if hmac
          hash = request.params.slice(:code, :shop, :timestamp)
          query = URI.escape(hash.sort.collect {|k, v| "#{k}=#{v}"}.join('&'))
          digest = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), ShopifyApp::Const::API_SECRET, query)
          ActiveSupport::SecurityUtils.secure_compare(hmac, digest)
        else
          false
        end
      end

      def get_shop_access_token(shop, code)
        url = "https://#{shop}/admin/oauth/access_token"

        payload = {
            client_id: ShopifyApp::Const::API_KEY,
            client_secret: ShopifyApp::Const::API_SECRET,
            code: code}

        response = HTTParty.post(url, body: payload)
        if response.code == 200
          response['access_token']
        end
      end

      def instantiate_session(myshopify_domain, token)
        ShopifyAPI::Session.setup(api_key: ShopifyApp::Const::API_KEY, secret: ShopifyApp::Const::API_SECRET)
        ShopifyAPI::Base.clear_session
        session = ShopifyAPI::Session.new(myshopify_domain, token)
        ShopifyAPI::Base.activate_session(session)
      end

      def persist_if_not_exists(myshopify_domain, access_token)
        self.instantiate_session(myshopify_domain, access_token)
        shopify_shop = ShopifyAPI::Shop.current
        if shopify_shop.present?
          store, changed = Store.create_or_update_from_shopify_shop(shopify_shop, access_token)
          SyncQueue.where(target: store).first_or_create if changed
          store
        end
      end

      def create_webhooks
        ShopifyApp::Const::EVENTS_TOPICS.each do |event, topics|
          topics.each do |topic|
            new_topic = "#{event}/#{topic}"
            new_address = "#{ShopifyApp::Const::BASE_URL}/api/products/shopify_webhook"
            #you may create as many webhooks as you want for each topic
            unless ShopifyAPI::Webhook.where(:topic => new_topic, :address => new_address).present?
              new_webhook_attrs = {
                  topic: new_topic,
                  address: new_address,
                  format: 'json'}
              ShopifyAPI::Webhook.create(new_webhook_attrs)
            end
          end
        end
      end

      def webhook_ok?(hmac, data)
        digest = OpenSSL::Digest.new('sha256')
        calculated_hmac = Base64.encode64(OpenSSL::HMAC.digest(digest, ShopifyApp::Const::API_SECRET, data)).strip

        ActiveSupport::SecurityUtils.secure_compare(hmac, calculated_hmac)
      end

    end
  end
end
