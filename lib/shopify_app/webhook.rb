module ShopifyApp
  class Webhook
    class << self

      def app_uninstalled(store, data_obj)
        #TODO do something after user uninstall our shopify app
        Rails.logger.debug data_obj
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
        #TODO do something after user delete a product
        product = Product.find_by_source_id(deleted_product.id)
        product.destroy if product
      end

      def shop_update(store, shopify_shop)
        #TODO do something after user updated shop
        Store.update_store_from_shopify_shop(store, shopify_shop)
      end

    end
  end
end
