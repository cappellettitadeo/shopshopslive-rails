module CentralApp
  class Const
    APP_BASE_URL = ENV['CTR_BASE_URL']
    API_ENDPOINTS = {
        category: {
            list: '/v1/intemodule/category/lst',
            query: '/v1/intemodule/category/query'
        },
        inventory: {
            update: '/v1/intemodule/inventory/update'
        },
        store: {
            list: '/v1/intemodule/store/lst',
            query: '/v1/intemodule/store/query'
        },
        vendor: {
            list: '/v1/intemodule/brand/lst',
            query: '/v1/intemodule/brand/query'
        },
        callback: {
            list: '/setting/callback'
        }
    }

    class StatusCode
      class ErrorCode
        TOKEN_EXPIRED = 6014
        WRONG_NUM_SEGMENTS = 6002
      end
    end

    class << self

      def callback_list_url
        Const::APP_BASE_URL + API_ENDPOINTS[:callback][:list]
      end

      def category_list_url
        Const::APP_BASE_URL + API_ENDPOINTS[:category][:list]
      end

      def category_query_url
        Const::APP_BASE_URL + API_ENDPOINTS[:category][:query]
      end

      def inventory_update_url
        Const::APP_BASE_URL + API_ENDPOINTS[:inventory][:update]
      end

      def store_list_url
        Const::APP_BASE_URL + API_ENDPOINTS[:store][:list]
      end

      def store_query_url
        Const::APP_BASE_URL + API_ENDPOINTS[:store][:query]
      end

      def vendor_list_url
        Const::APP_BASE_URL + API_ENDPOINTS[:vendor][:list]
      end

      def vendor_query_url
        Const::APP_BASE_URL + API_ENDPOINTS[:vendor][:query]
      end

      def default_headers
        api_key = ApiKey.find_by_name("shopshops")
        if api_key&.auth_token && api_key.key
          {
              "Content-type": "application/json",
              token: api_key.auth_token,
              uid: api_key.key,
              typ:  "JWT"
          }
        else
          return default_headers if Utils::Token.get_token
        end
      end
    end
  end
end
