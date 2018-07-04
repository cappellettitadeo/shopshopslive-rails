module CentralApp
  class Const
    API_KEY = ENV['CTR_API_KEY']
    API_SECRET = ENV['CTR_API_SECRET']
    APP_BASE_URL = ENV['CTR_APP_URL']
    API_ENDPOINTS = {
      category: {
        list: '/intemodule/category/lst',
        query: '/intemodule/category/query'
      },
      inventory: {
        update: '/intemodule/inventory/update'
      }
    }

    class << self
      def category_list
        API_BASE_URL + API_ENDPOINTS[:category][:list]
      end

      def category_query
        API_BASE_URL + API_ENDPOINTS[:category][:query]
      end

      def inventory_update
        API_BASE_URL + API_ENDPOINTS[:inventory][:update]
      end
    end
  end
end
