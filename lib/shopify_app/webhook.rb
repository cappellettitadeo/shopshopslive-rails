module ShopifyApp
  class Webhook
    class << self

      def app_uninstalled(data_obj)
        Rails.logger.debug data_obj
      end

      def products_create(store, product)
        scraper = Scraper.create(source_type: store.source_type, url: store.source_url)
        scraper.save

        ShopifyCreateProductWorker.new.perform(store, product, scraper)
      end

      def products_update(updated_product)
        Product.update_from_shopify_product(updated_product)
      end

      def products_delete(product)
        Product.find_by_source_id(product.id).destroy
      end

      def shop_update(shop)
        Rails.logger.debug shop
      end

    end
  end
end