require 'httparty'

module CentralApp
  class Utils
    class Category
      class << self

        def list_all
          url = Const.category_list_url
          res = HTTParty.get(url)
          parsed_json = JSON.parse res
          parsed_json[:data][:categories]
        end

        def query(keyword)
          url = Const.category_query_url
          res = HTTParty.get(url, query: { keyword: keyword })
          parsed_json = JSON.parse res
          parsed_json[:data]
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
          res = HTTParty.get(url)
          parsed_json = JSON.parse res
          parsed_json[:data][:stores]
        end

        def query(keyword)
          url = Const.store_query_url
          res = HTTParty.get(url, query: { keyword: keyword })
          parsed_json = JSON.parse res
          parsed_json[:data]
          ## Subcategroy
          # parsed_json[:data][:subItem]
          # cat_1st_name = parsed_json[:category_1st_name]
          # cat_1st_id = parsed_json[:category_1st_id]
          # cat_2nd_name = parsed_json[:category_2nd_name]
          # cat_2nd_id = parsed_json[:category_2nd_id]
        end
      end
    end
  end
end
