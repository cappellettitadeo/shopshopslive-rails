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
          Product.create_or_update_from_shopify_object(product_result)
        end
      end

      def product_listings_remove(deleted_product)
        product = Product.find_by_source_id(deleted_product.id)
        product.destroy if product
      end

      def shop_update(store, shopify_shop)
        Store.update_store_from_shopify_shop(store, shopify_shop)
      end

    end
  end
end
