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

      def get_shop_access_token(shop, client_id, client_secret, code)
        url = "https://#{shop}/admin/oauth/access_token"

        payload = {
            client_id: client_id,
            client_secret: client_secret,
            code: code}

        response = HTTParty.post(url, body: payload)
        # if the response is successful, obtain the token and store it in a hash
        if response.code == 200
          response['access_token']
        else
          [500, "Something went wrong."]
        end
      end

      def instantiate_session(shop, token)
        session = ShopifyAPI::Session.new(shop, token)
        ShopifyAPI::Base.activate_session(session)
      end

      def create_new_store(access_token)
        shop = ShopifyAPI::Shop.current
      end


      def create_webhooks
        ShopifyApp::Const::EVENTS_TOPICS.each do |event, topics|
          topics.each do |topic|
            new_topic = "#{event}/#{topic}"
            new_address = "#{ShopifyApp::Const::APP_URL}/#{event}_#{topic}"
            #you may create as many webhooks as you want for one of the topics
            unless ShopifyAPI::Webhook.where(:topic => new_topic, :address => new_address).any?
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
