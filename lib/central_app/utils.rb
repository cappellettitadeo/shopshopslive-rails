require 'httparty'

module CentralApp
  class Utils
    class << self
      def list_all(model, url)
        retries = Const::MAX_NUM_OF_ATTEMPTS
        begin
          headers = Const.default_headers
          if headers
            res = HTTParty.get(url, headers: headers)
            parsed_json = JSON.parse(res.body).with_indifferent_access
            if parsed_json
              status_code = parsed_json[:code]
              case status_code
              when 200
                if parsed_json[:data].is_a? Array
                  parsed_json[:data]
                else
                  parsed_json[:data][model.to_sym]
                end
              else
                raise res
              end
            end
          end
        rescue
          retries -= 1
          retry if retries >0 && Token.get_token
        end
      end

      def query(keyword, url)
        retries = Const::MAX_NUM_OF_ATTEMPTS
        begin
          headers = Const.default_headers
          if headers
            res = HTTParty.get(url, headers: headers, query: { keyword: keyword })
            parsed_json = JSON.parse(res.body).with_indifferent_access
            status_code = parsed_json[:code]
            case status_code
            when 200
              parsed_json[:data]
            else
              raise res
            end
          end
        rescue
          retries -= 1
          retry if retries > 0 && Token.get_token
        end
      end
    end

    class Callback
      class << self
        def list_all
          url = Const.callback_list_url
          res = HTTParty.get(url)
          JSON.parse(res.body).with_indifferent_access unless res.code == 500
        end
      end
    end

    class Category
      class << self

        def list_all
          url = Const.category_list_url
          Utils.list_all('categories', url)
        end

        def query(keyword)
          url = Const.category_query_url
          Utils.query(keyword, url)

          ## Subcategroy
          # parsed_json[:data][:subItem]
          # cat_1st_name = parsed_json[:category_1st_name]
          # cat_1st_id = parsed_json[:category_1st_id]
          # cat_2nd_name = parsed_json[:category_2nd_name]
          # cat_2nd_id = parsed_json[:category_2nd_id]
        end
      end
    end

    class Store
      class << self

        def list_all
          url = Const.store_list_url
          Utils.list_all('stores', url)
        end

        def query(keyword)
          url = Const.store_query_url
          Utils.query(keyword, url)
          ## Subcategroy
          # parsed_json[:data][:subItem]
          # cat_1st_name = parsed_json[:category_1st_name]
          # cat_1st_id = parsed_json[:category_1st_id]
          # cat_2nd_name = parsed_json[:category_2nd_name]
          # cat_2nd_id = parsed_json[:category_2nd_id]
        end
      end
    end

    class Token
      class << self
        def get_token
          retries = Const::MAX_NUM_OF_ATTEMPTS
          begin
            url = "#{ENV['CTR_BASE_URL']}/getToken"
            res = HTTParty.get(url, query: {name: ENV['CTR_USERNAME'], pwd: ENV['CTR_PASSWORD']})
            parsed_json = JSON.parse res.body
            if parsed_json['code'] == 200
              api_key = ApiKey.where(name: "shopshops").first_or_create
              api_key.auth_token = parsed_json['data']['token']
              api_key.key = parsed_json['data']['uid']
              api_key.save
              api_key
            else
              raise res
            end
          rescue
            retries -= 1
            retry if retries > 0
          end
        end
      end
    end

    class Vendor
      class << self
        def list_all
          url = Const.vendor_list_url
          Utils.list_all('brands', url)
        end

        def query(keyword)
          url = Const.vendor_query_url
          Utils.query(keyword, url)
        end
      end
    end

  end
end
