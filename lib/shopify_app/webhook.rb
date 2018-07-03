module ShopifyApp
  class Webhook
    class << self

      def app_uninstalled(data_obj)
        #TODO do something after user uninstall our shopify app
        Rails.logger.debug data_obj
      end

      def products_create(store, product)
        product_result = Scrapers::Shopify::Result.new(store, product, nil)
        Product.create_from_shopify_object(store, product_result)
      end

      def products_update(updated_product)
        Product.update_from_shopify_product(updated_product)
      end

      def products_delete(deleted_product)
        product = Product.find_by_source_id(deleted_product.id)
        product.destroy if product
      end

      def shop_update(store, updated_shop)
        Store.update_store_from_shopify_shop(store, updated_shop)
      end

    end
  end
end