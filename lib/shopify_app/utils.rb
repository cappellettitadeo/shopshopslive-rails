require 'httparty'

module ShopifyApp
  class Utils

    class << self
      EVENTS_TOPICS = {
          :products => %w(create delete update),
          :shop => %w(update),
          :app => %w(uninstalled)}

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

      def create_webhooks

        EVENTS_TOPICS.each do |event, topics|
          topics.each do |topic|
            unless ShopifyAPI::Webhook.find(:all, :params => {:topic => "#{event}/#{topic}"}).any?
              new_webhook_attrs = {
                  topic: "#{event}/#{topic}",
                  address: "#{ShopifyApp::Const::APP_URL}/#{event}_#{topic}",
                  format: 'json'}
              ShopifyAPI::Webhook.create(new_webhook_attrs)
            end
          end
        end
        Rails.logger.debug ShopifyAPI::Webhook.find(:all)
      end

    end
  end
end
