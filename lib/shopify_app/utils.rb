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

      # Exchange temp code to permernant access_token
      def get_shop_access_token(shop, code)
        url = "https://#{shop}/admin/oauth/access_token"

        payload = {
            client_id: ShopifyApp::Const::API_KEY,
            client_secret: ShopifyApp::Const::API_SECRET,
            code: code}

        response = HTTParty.post(url, body: payload)
        if response.code == 200
          response['access_token']
        else
          Rails.logger.warn response
        end
      end

      # Payment using Stripe token
      def submit_payment_by_stripe(shop, access_token, checkout, stripe_token)
        url = "https://#{shop}/admin/checkouts/#{checkout.id}/payments.json"
        headers = {
          "X-Shopify-Access-Token": "#{access_token}",
          "X-Shopify-Checkout-Version": "2016-08-28",
          "Content-Type": "application/json",
          "Host": "#{shop}"
        }

        # unique_token is a unique token defined by us
        payload = {
          "payment": {
            "amount": "#{checkout.total_price}",
            "unique_token": "#{checkout.id}_" + Time.now.to_i.to_s,
            "payment_token": {
              "payment_data": "#{stripe_token.id}",
              "type": "stripe_vault_token"
            },
            "request_details": {
              "ip_address": ShopifyApp::Const::SERVER_DEPLOY_IP,
              "accept_language": "en",
              "user_agent": ShopifyApp::Const::USER_AGENT,
            }
          },
        }.to_json

        response = HTTParty.post(url, :body => payload, :headers => headers)
        if response.code == 200
          p response
        else
          Rails.logger.warn response
        end
      end

      # Direct payment via Shopify
      def submit_payment_by_shopify(shop, access_token, checkout, cc_session_id)
        url = "https://#{shop}/admin/checkouts/#{checkout.id}/payments.json"
        headers = {
          "X-Shopify-Access-Token": "#{access_token}",
          "X-Shopify-Checkout-Version": "2016-08-28",
          "Content-Type": "application/json",
          "Host": "#{shop}"
        }

        payload = {
          "payment": {
            "amount": "#{checkout.total_price}",
            "unique_token": "#{checkout.id}_" + Time.now.to_i.to_s,
            "session_id": "#{cc_session_id}",
            "request_details": {
              "ip_address": ShopifyApp::Const::SERVER_DEPLOY_IP,
              "accept_language": "en",
              "user_agent": ShopifyApp::Const::USER_AGENT,
            }
          },
        }.to_json

        response = HTTParty.post(url, :body => payload, :headers => headers)
        if response.code == 200
          p response
        else
          Rails.logger.warn response
        end
      end

      # Submit card detail onto Shopify vault
      def submit_card_to_vault(checkout, card)
        url = "https://elb.deposit.shopifycs.com/sessions"
        headers = {
          "Content-Type": "application/json",
          "Accept": "application/json"
        }

        payload = {
          "payment": {
            "amount": "#{checkout.total_price}",
            "unique_token": "#{checkout.id}_" + Time.now.to_i.to_s,
            "credit_card": {
              "number": "#{card[:number]}",
              "month": "#{card[:month]}",
              "year": "#{card[:year]}",
              "verification_value": "#{card[:cvc]}",
              "first_name": "#{card[:first_name]}",
              "last_name": "#{card[:last_name]}"
            }
          },
        }.to_json

        response = HTTParty.post(url, :body => payload, :headers => headers)
        if response.code == 200
          p response
        else
          Rails.logger.warn response
        end
      end

      def retrieve_payment(shop, access_token, checkout, payment_id)
        url = "https://#{shop}/admin/checkouts/#{checkout.id}/payments/#{payment_id}.json"
        headers = {
          "X-Shopify-Access-Token": "#{access_token}",
          "X-Shopify-Checkout-Version": "2016-08-28",
          "Content-Type": "application/json",
          "Host": "#{shop}"
        }

        response = HTTParty.get(url, :headers => headers)
        if response.code == 200
          p response
        else
          Rails.logger.warn response
        end
      end

      def polling_for_shipping(shop, access_token, checkout)
        url = "https://#{shop}/admin/checkouts/#{checkout.id}/shipping_rates.json"
        headers = {
          "X-Shopify-Access-Token": "#{access_token}",
          "Content-Type": "application/json",
          "Host": "#{shop}"
        }

        try_again = true
        while try_again
          response = HTTParty.get(url, :headers => headers)
          if response.code == 200
            try_again = false
            return response["shipping_rates"]
          elsif response.code == 202
            # Should retry when shipping_rate not ready
            sleep 0.05
          else
            try_again = false
            Rails.logger.warn response
          end
        end
      end

      def retrieve_checkout(shop, access_token, checkout)
        url = "https://#{shop}/admin/checkouts/#{checkout.id}.json"
        headers = {
          "X-Shopify-Access-Token": "#{access_token}",
          "Content-Type": "application/json",
          "Host": "#{shop}"
        }

        response = HTTParty.get(url, :headers => headers)
        if response.code == 200
          p response
        else
          Rails.logger.warn response
        end
      end

      def select_shipping_rate(shop, access_token, checkout, shipping_handle)
        url = "https://#{shop}/admin/checkouts/#{checkout.id}.json"
        headers = {
          "X-Shopify-Access-Token": "#{access_token}",
          "Content-Type": "application/json",
          "Host": "#{shop}"
        }

        payload = {
          "checkout": {
            "token": "#{checkout.id}",
            "shipping_line": {
              "handle": "#{shipping_handle}"
            }
          }
        }.to_json

        response = HTTParty.patch(url, :headers => headers, :body => payload)
        if response.code == 200
          p response
        else
          Rails.logger.warn response
        end
      end

      def instantiate_session(myshopify_domain, token)
        ShopifyAPI::Base.clear_session
        ShopifyAPI::Session.setup(api_key: ShopifyApp::Const::API_KEY, secret: ShopifyApp::Const::API_SECRET)
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
