require 'httparty'

module CentralApp
  class Utils
    class << self
      def list_all(model, url)
        retry_count = 0
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
          retry_count += 1
          if retry_count < Const::MAX_NUM_OF_ATTEMPTS && CentralApp::Utils::Token.get_token
            #sleep(sec_till_next_try(retry_count))
            retry
          end
        end
      end

      def query(keyword, url)
        retry_count = 0
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
          retry_count += 1
          if retry_count < Const::MAX_NUM_OF_ATTEMPTS && CentralApp::Utils::Token.get_token
            #sleep(sec_till_next_try(retry_count))
            retry
          end
        end
      end

      def sec_till_next_try(retry_count)
        (retry_count ** 4) + 15 + (rand(30) * (retry_count + 1))
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

    class StoreC
      class << self
        def list_all
          url = Const.store_list_url
          Utils.list_all('stores', url)
        end

        def query(keyword)
          url = Const.store_query_url
          Utils.query(keyword, url)
        end

        def sync(stores)
          store_setting = CallbackSetting.stores.first
          url = store_setting.url
          stores_hash = StoreSerializer.new(stores).serializable_hash

          body = { count: stores.count, stores: stores_hash[:data] }.to_json
          puts "Stores:"
          retry_count = 0
          begin
            headers = CentralApp::Const.default_headers
            res = HTTParty.post(url, { headers: headers, body: body })
            puts "Res:"
            parsed_json = JSON.parse(res.body).with_indifferent_access
            if parsed_json[:code] != 200
              raise res
            elsif res['data'] && res['data']['insert']
              ## Update ctr_store_id from the response
              res['data']['insert'].each do |row|
                store = Store.where(id: row['id']).first
                store.update_attributes(ctr_store_id: row['oid'])
              end
            end
          rescue
            retry_count += 1
            if retry_count == CentralApp::Const::MAX_NUM_OF_ATTEMPTS
              return false
            end
            if retry_count < CentralApp::Const::MAX_NUM_OF_ATTEMPTS && CentralApp::Utils::Token.get_token
              retry
            end
          end
        end
      end
    end

    class Token
      class << self
        def get_token
          retry_count = 0
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
            retry_count += 1
            if retry_count < Const::MAX_NUM_OF_ATTEMPTS
              #sleep(Utils.sec_till_next_try(retry_count))
              retry
            end
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

        # TODO: Not working
        def query(keyword)
          url = Const.vendor_query_url
          Utils.query(keyword, url)
        end
      end
    end

  end
end
