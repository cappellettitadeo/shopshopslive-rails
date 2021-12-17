require 'httparty'

module ShopifyApp
  class Order
    API_VERSION = "2020-07"

    class << self

      def create_customer(user, store)
        url = "https://#{store.source_url}/admin/api/#{API_VERSION}/customers.json"
        ShopifyApp::Utils.instantiate_session(store.source_url, store.source_token)
        payload = {
          customer: {
            first_name: user.first_name,
            last_name: user.last_name,
            name: user.full_name,
            email: user.email,
            phone: user.phone,
            addresses: []
          }
        }
        user.shipping_addresses.each do |add|
          payload[:customer][:addresses] << add.as_json(except: [:id, :user_id, :source_id, :created_at, :updated_at, :full_name])
        end
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
          shipping_address: add.as_json(except: [:id, :user_id, :source_id, :created_at, :updated_at, :full_name])
        }
        res = HTTParty.post(url, body: payload)
        if res.code == 201
          res
        else
          Rails.logger.warn res
          raise "Shopify Error: " + res["errors"] 
        end
      end

      def create_draft_order(store, order)
        url = "https://#{store.source_url}/admin/api/#{API_VERSION}/draft_orders.json"
        ShopifyApp::Utils.instantiate_session(store.source_url, store.source_token)
        items = []
        order.line_items.each do |li|
          items << { variant_id: li.product_variant.source_id, quantity: li.quantity, requires_shipping: true  }
        end
        puts 'master order'
        puts order.master_order
        if order.master_order.present?
          address = order.master_order.shipping_address
        else
          address = order.shipping_address
        end
        payload = {
          draft_order: {
            line_items: items,
            note: order.note,
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
        puts "Shopify reqeust url: #{url}"
        puts "Shopify reqeust header:"
        puts headers
        puts "Shopify reqeust body:"
        puts payload
        res = HTTParty.post(url, body: payload, headers: headers)
        Rails.logger.warn res
        if res.code == 201 || res.code == 202
          res["draft_order"]
        else
          puts res.code
          puts "Error"
          raise "Shopify Error: " + res["errors"] 
        end
      end

      def update_draft_order(store, order)
        url = "https://#{store.source_url}/admin/api/#{API_VERSION}/draft_orders/#{order.source_id}.json"
        ShopifyApp::Utils.instantiate_session(store.source_url, store.source_token)
        items = []
        order.line_items.each do |li|
          items << { variant_id: li.product_variant.source_id, quantity: li.quantity, requires_shipping: true  }
        end
        if order.order_type == 1
          address = order.master_order.shipping_address
        else
          address = order.shipping_address
        end
        payload = {
          draft_order: {
            line_items: items,
            note: order.note,
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
        puts "Shopify reqeust url: #{url}"
        puts "Shopify reqeust header:"
        puts headers
        puts "Shopify reqeust body:"
        puts payload
        res = HTTParty.put(url, body: payload, headers: headers)
        puts res
        Rails.logger.warn res
        if res.code == 200
          res["draft_order"]
        else
          Rails.logger.warn res
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

      def get_order(store, order)
        url = "https://#{store.source_url}/admin/api/#{API_VERSION}/orders/#{order.source_id}.json"
        ShopifyApp::Utils.instantiate_session(store.source_url, store.source_token)
        headers = {
          "X-Shopify-Access-Token": store.source_token
        }
        res = HTTParty.get(url, headers: headers)
        Rails.logger.warn res
        if res.code == 200
          res["order"]
        else
          raise "Shopify Error: " + res["errors"].to_s
        end
      end

      def calculate_refund(store, order, line_items)
        url = "https://#{store.source_url}/admin/api/#{API_VERSION}/orders/#{order.source_id}/refunds/calculate.json"
        ShopifyApp::Utils.instantiate_session(store.source_url, store.source_token)
        headers = {
          "X-Shopify-Access-Token": store.source_token
        }
        items = []
        line_items.each do |li|
          item = li[0].reload
          quantity = li[1]
          items << { line_item_id: item.source_id, quantity: quantity, restock_type: 'no_restock'  }
        end
        payload = {
          refund: {
            refund_line_items: items,
          }
        }
        puts "Shopify reqeust url: #{url}"
        puts "Shopify reqeust header:"
        puts headers
        puts "Shopify reqeust body:"
        puts payload
        res = HTTParty.post(url, body: payload, headers: headers)
        Rails.logger.warn res
        if res.code == 200
          res["refund"]
        else
          raise "Shopify Error: " + res["errors"].to_s
        end
      end

      def refund(store, order, line_items)
        # 1. Calculate refund
        res = calculate_refund(store, order, line_items)
        new_trans = []
        res["transactions"].each do |trans|
          if trans["kind"] == 'suggested_refund' 
            trans["kind"] = 'refund'  
            new_trans << trans
          end
        end
        if new_trans.present?
          res["transactions"] = new_trans
        else
          raise "Shopify Error: " + res
        end
        # 2. use response for refund submission
        url = "https://#{store.source_url}/admin/api/#{API_VERSION}/orders/#{order.source_id}/refunds.json"
        ShopifyApp::Utils.instantiate_session(store.source_url, store.source_token)
        headers = {
          "X-Shopify-Access-Token": store.source_token
        }
        payload = {
          refund: res
        }
        puts "Shopify reqeust url: #{url}"
        puts "Shopify reqeust header:"
        puts headers
        puts "Shopify reqeust body:"
        puts payload
        res = HTTParty.post(url, body: payload, headers: headers)
        trans = res['refund']['transactions'].first
        status = trans['status']
        Rails.logger.warn res
        if res.code == 201 && status == 'success'
          res["refund"]
        else
          raise "Shopify Refund Error: " + trans['error_code']
        end
      end
    end
  end
end
