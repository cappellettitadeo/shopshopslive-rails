require 'httparty'

module ShopifyApp
  class Utils

    class << self

      def valid_request_from_shopify?(request)
        hmac = request.params['hmac']

        if not hmac.nil?
          hash = request.params.reject {|k, _| k == 'hmac' || k == 'controller' || k == 'action'}
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
        # if the response is successful, obtain the token and store it in a hash
        if response.code == 200
          response['access_token']
        else
          [500, "Something went wrong."]
        end
      end

      def instantiate_session(myshopify_domain, token)
        ShopifyAPI::Base.clear_session
        session = ShopifyAPI::Session.new(myshopify_domain, token)
        ShopifyAPI::Base.activate_session(session)
      end

      def persist_if_not_exists(myshopify_domain, access_token)
        unless Store.find_by(source_url: myshopify_domain).present?
          self.instantiate_session(myshopify_domain, access_token)
          shopify_shop = ShopifyAPI::Shop.current
          store = Store.new name: shopify_shop.name, description: '', country: shopify_shop.country_code,
                            website: shopify_shop.domain, phone: shopify_shop.phone, currency: shopify_shop.currency,
                            street: shopify_shop.address1, city: shopify_shop.city,
                            unit_no: shopify_shop.address2, zipcode: shopify_shop.zip,
                            latitude: shopify_shop.latitude, longitude: shopify_shop.longitude, local_rate: nil,
                            source_url: myshopify_domain, source_token: access_token, source_id: shopify_shop.id, source_type: 'shopify'
          return store.save
        end
        false
      end

      def create_webhooks
        ShopifyApp::Const::EVENTS_TOPICS.each do |event, topics|
          topics.each do |topic|
            new_topic = "#{event}/#{topic}"
            new_address = "#{ShopifyApp::Const::BASE_URL}//api/products/shopify_webhook"
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
