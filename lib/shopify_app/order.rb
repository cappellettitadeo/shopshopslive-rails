require 'httparty'

module ShopifyApp
  class Order
    API_VERSION = "2020-07"

    class << self

      def create_customer(store_url, store_token, check_out)
        url = "https://#{store_url}/admin/api/#{API_VERSION}/draft_orders.json"
        ShopifyApp::Utils.instantiate_session(store_url, store_token)
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

        if res.code == 200
        else
          raise res["errors"] 
        end
      end

      def create_draft_order(store_url, store_token, order)
        url = "https://#{store_url}/admin/api/#{API_VERSION}/draft_orders.json"
        ShopifyApp::Utils.instantiate_session(store_url, store_token)
        #items = []
        #line_items.each do |i|
        #  items << { variant_id: '31509288517689', quantity: 1 }
        #end
          
        order.line_items.each do |li|
          items << { variant_id: li.source_id, quantity: li.quantity, requires_shipping: true  }
        end

        items = [{ variant_id: '31509288517689', quantity: 1, requires_shipping: true }] 
        payload = {
          draft_order: {
            line_items: items
          },
          customer: { id: 1 },
          use_customer_default_address: true
        }
        response = HTTParty.post(url, body: payload)

        binding.pry
        if response.code == 200
          p response
        else
          Rails.logger.warn response
        end
      end

      def update_draft_order(store_url, store_token, check_out)
        url = "https://#{store_url}/admin/api/#{API_VERSION}/draft_orders.json"
        ShopifyApp::Utils.instantiate_session(store_url, store_token)
      end
    end
  end
end
