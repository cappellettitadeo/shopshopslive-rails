module ShopifyApp
  class Webhook
    class << self

      def app_uninstalled(store)
        #update store's status and its products (along with product's variants) availability if user uninstall our app
        if store
          store.update(status: 'inactive')
          SyncQueue.where(target: store)
          if store.products.present?
            store.products.each do |product|
              product.update(available: false)
              SyncQueue.where(target: product)
              if product.product_variants.present?
                product.product_variants.each do |product_variant|
                  product_variant.update(available: false)
                end
              end
            end
          end
        end
      end

      def product_listings_add_or_update(store, object)
        updated_product = object.product_listing
        if updated_product
          Rails.logger.debug updated_product
          Rails.logger.debug updated_product.product_id
          product_result = Scrapers::Shopify::Result.new(store, updated_product, nil)
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

      def shop_update(store, shopify_shop)
        Store.update_store_from_shopify_shop(store, shopify_shop)
      end

    end
  end
end
