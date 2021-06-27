module ShopifyApp
  class Webhook
    class << self

      def app_uninstalled(store)
        #update store's status and its products (along with product's variants) availability if user uninstall our app
        if store
          store.update(status: 'inactive')
          SyncQueue.where(target: store).first_or_create
          if store.products.present?
            store.products.each do |product|
              product.update(available: false)
              SyncQueue.where(target: product).first_or_create
              if product.product_variants.present?
                product.product_variants.each do |product_variant|
                  product_variant.update(available: false)
                end
              end
            end
          end
        end
      end

      def product_listings_add_or_update(store, object, source = 'product_listing')
        updated_product = object.product_listing
        if updated_product
          product_result = Scrapers::Shopify::Result.new(store, updated_product, nil, source)
          product, changed = Product.create_or_update_from_shopify_object(product_result)
          SyncQueue.where(target: product).first_or_create if changed
        end
      end

      def product_listings_remove(deleted_product)
        product = Product.find_by_source_id(deleted_product.product_listing.product_id)
        if product
          product.available = false
          product.save
          if product.product_variants.present?
            product.product_variants.each do |variant|
              variant.update(available: false)
            end
          end
          SyncQueue.where(target: product).first_or_create
        end
      end

      def shop_update(shopify_shop)
        store, changed = Store.create_or_update_from_shopify_shop(shopify_shop)
        SyncQueue.where(target: store).first_or_create if changed
      end

      def fulfill(object)
        order = ::Order.find_by_source_id(object.order_id)
        if order
          if object.status == 'success'
            order.tracking_url = object.tracking_url
            order.tracking_no = object.tracking_number
            order.tracking_company = object.tracking_company
            order.shipping_status = object.shipping_status
            order.status = 'fulfilled'
          elsif object.status == 'cancelled'
            order.tracking_url = nil
            order.shipping_status = 'cancelled'
            order.status = 'paid'
          elsif object.status == 'refund'
            order.status = 'refund'
          elsif object.status == 'failure'
            order.status = 'fulfill_failed'
            order.shipping_status = 'failure'
          end
          order.save
        end
        # Trigger callback to Central system
        # TODO waiting for ctr to provide url
        url = ''
        json = OrderSerializer.new(order.reload).serializable_hash.to_json
        retry_count = 0
        begin
          headers = CentralApp::Const.default_headers
          res = HTTParty.post(url, { headers: headers, body: json })
          parsed_json = JSON.parse(res.body).with_indifferent_access
          if parsed_json[:code] != 200
            raise res
          end
        rescue
          retry_count += 1
          if retry_count == CentralApp::Const::MAX_NUM_OF_ATTEMPTS
            return false
          end
          if retry_count < CentralApp::Const::MAX_NUM_OF_ATTEMPTS && CentralApp::Utils::Token.get_token
            retry
          end
        end
      end
    end
  end
end
