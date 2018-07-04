module ShopifyApp
  class Webhook
    class << self

      def app_uninstalled(store, data_obj)
        #TODO do something after user uninstall our shopify app
        Rails.logger.debug data_obj
      end

      def products_create(store, product)
        product_result = Scrapers::Shopify::Result.new(store, product, nil)
        Product.create_from_shopify_object(store, product_result)
      end

      def products_update(store, updated_product)
        product_result = Scrapers::Shopify::Result.new(store, updated_product, nil)
        Product.update_from_shopify_product(store, product_result)
      end

      def products_delete(deleted_product)
        product = Product.find_by_source_id(deleted_product.id)
        product.destroy if product
      end

      def shop_update(store, shopify_shop)
        Store.update_store_from_shopify_shop(store, shopify_shop)
      end

    end
  end
end