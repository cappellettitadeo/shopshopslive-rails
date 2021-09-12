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
        if changed
          CentralApp::Utils::StoreC.sync([store])
        end
      end

      def fulfill(object, type)
        if type == 'fulfillment'
          order = ::Order.find_by_source_order_id(object.order_id)
        elsif type == 'order'
          order = ::Order.find_by_source_order_id(object.id) || ::Order.find_by_source_id(object.id)
        end
        puts "Fulfill Order:"
        puts order
        return unless order
        order.fulfill_obj = object
        if object.status == 'success'
          order.tracking_url = object.tracking_url
          order.tracking_no = object.tracking_number
          order.tracking_company = object.tracking_company
          order.shipping_status = object.shipment_status
          #order.status = 'fulfilled'
          puts "Success"
        elsif object.status == 'cancelled'
          order.tracking_url = nil
          order.shipping_status = 'cancelled'
          order.status = 'cancelled'
        elsif object.status == 'refund'
          order.status = 'refund'
        elsif object.status == 'failure'
          order.status = 'fulfill_failed'
          order.shipping_status = 'failure'
        end
        if order.status_changed? || order.shipping_status_changed?
          order.save
        else
          return
        end
        if order.source_order_id
          order.sync_with_central_system(object)
        end
      end
    end
  end
end
