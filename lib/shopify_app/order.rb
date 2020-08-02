require 'httparty'

module ShopifyApp
  class Order
    API_VERSION = "2020-07"

    class << self

      def create_customer(store, check_out)
        url = "https://#{store.source_url}/admin/api/#{API_VERSION}/draft_orders.json"
        ShopifyApp::Utils.instantiate_session(store.source_url, store.source_token)
        #items = []
        #line_items.each do |i|
        #  items << { variant_id: '31509288517689', quantity: 1 }
        #end
        items = [{ variant_id: '31509288517689', quantity: 1 }] 

        payload = {
          draft_order: {
            line_items: items
          }
        }
        res = HTTParty.post(url, body: payload)

        if res.code == 201
        else
          raise res["errors"] 
        end
      end

      def create_shipping_address(store, customer_id, address)
        url = "https://#{store.source_url}/admin/api/#{API_VERSION}/customers/#{customer_id}/address.json"
        ShopifyApp::Utils.instantiate_session(store.store.source_url, store.source_token)
        payload = {
          shipping_address: {
            address1: address.address1,
            address2: address.address2,
            first_name: address.first_name,
            last_name: address.last_name,
            name: address.full_name,
            city: address.city,
            province: address.province,
            country: address.country,
            zip: address.zip,
            phone: address.phone
          }
        }
        response = HTTParty.post(url, body: payload)
        if response.code == 201
          response
        else
          Rails.logger.warn response
        end
      end

      def create_draft_order(store, order)
        user_id = order.user.source_id
        url = "https://#{store.source_url}/admin/api/#{API_VERSION}/draft_orders.json"
        ShopifyApp::Utils.instantiate_session(store.source_url, store.source_token)
        items = []
        order.line_items.each do |li|
          items << { variant_id: li.product_variant.source_id, quantity: li.quantity, requires_shipping: true  }
        end
        address = order.shipping_address
        payload = {
          draft_order: {
            line_items: items,
            customer: { id: user_id },
            shipping_address: {
              address1: address.address1,
              address2: address.address2,
              first_name: address.first_name,
              last_name: address.last_name,
              name: address.full_name,
              city: address.city,
              province: address.province,
              country: address.country,
              zip: address.zip,
              phone: address.phone
            }
          }
        }
        headers = {
          "X-Shopify-Access-Token": store.source_token
        }
        res = HTTParty.post(url, body: payload, headers: headers)
        Rails.logger.warn res
        if res.code == 201
          res["draft_order"]
        else
          raise "Shopify Error: " + res["errors"] 
        end
      end

      def complete_draft_order(store, order)
        url = "https://#{store.source_url}/admin/api/#{API_VERSION}/draft_orders/#{order.source_id}/complete.json"
        ShopifyApp::Utils.instantiate_session(store.source_url, store.source_token)
        headers = {
          "X-Shopify-Access-Token": store.source_token
        }
        res = HTTParty.put(url, headers: headers)
        Rails.logger.warn res
        if res.code == 200
          res["draft_order"]
        else
          raise "Shopify Error: " + res["errors"].to_s
        end
      end

      def update_draft_order(store, check_out)
        url = "https://#{store.source_url}/admin/api/#{API_VERSION}/draft_orders.json"
        ShopifyApp::Utils.instantiate_session(store.source_url, store.source_token)
      end
    end
  end
end
