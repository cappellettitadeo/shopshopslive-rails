require 'central_app'

class ProductsSyncWorker
  include Sidekiq::Worker

  sidekiq_options unique: true, retry: 3

  def perform
    product_setting = CallbackSetting.product.first
    vendor_setting = CallbackSetting.vendor.first
    store_setting = CallbackSetting.stores.first
    # 如果mode不是"bunch"，则直接返回
    return unless product_setting &.bunch_update?

    SyncQueue.products.find_in_batches(batch_size: product_setting.bunch_size) do |items|
      products = items.collect(&:target)
      ## 1. Find all unique vendors from these products
      vendors = products.collect(&:vendor).uniq
      # 1.1 Create/Update vendors to Central System
      url = vendor_setting.url
      vendors_hash = VendorSerializer.new(vendors).serializable_hash

      # 1.2 POST to Central System
      body = { count: vendors.count, brands: vendors_hash[:data] }.to_json
      retry_count = 0
      begin
        headers = CentralApp::Const.default_headers
        res = HTTParty.post(url, { headers: headers, body: body })
        if res.code != 200
          raise res
          #return false
        else
          ## TODO Update ctr_vendor_id from the response
        end
      rescue
        retry_count += 1
        if retry_count == CentralApp::Const::MAX_NUM_OF_ATTEMPTS
          Airbrake.notify({ error_message: "Failed to post to #{url}", parameters: {
              callback_setting_id: vendor_setting.id,
              body: body,
              response: res
          }})
          return false
        end
         if retry_count < CentralApp::Const::MAX_NUM_OF_ATTEMPTS && CentralApp::Utils::Token.get_token
           #sleep(CentralApp::Utils.sec_till_next_try(retry_count))
           retry
         end
      end


      ## 2. Find all stores from these products
      stores = products.collect(&:store).uniq
      # 2.1 Create/Update stores to Central System
      url = store_setting.url
      stores_hash = StoreSerializer.new(stores).serializable_hash

      # 2.2 POST to Central System
      body = { count: stores.count, stores: stores_hash[:data] }.to_json
      retry_count = 0
      begin
        headers = CentralApp::Const.default_headers
        res = HTTParty.post(url, { headers: headers, body: body })
        if res.code != 200
          raise res
          #return false
        else
          ## TODO Update ctr_store_id from the response
        end
      rescue
        retry_count += 1
        if retry_count == CentralApp::Const::MAX_NUM_OF_ATTEMPTS
          Airbrake.notify({ error_message: "Failed to post to #{url}", parameters: {
              callback_setting_id: store_setting.id,
              body: body,
              response: res
          }})
          return false
        end
        if retry_count < CentralApp::Const::MAX_NUM_OF_ATTEMPTS && CentralApp::Utils::Token.get_token
          #sleep(CentralApp::Utils.sec_till_next_try(retry_count))
          retry
        end
      end
      ## 3. Create/Update products to Central System
      url = product_setting.url
      products_hash = ProductSerializer.new(products).serializable_hash
      body = { count: products.count, products: products_hash[:data] }.to_json
      retry_count = 0
      begin
        headers = CentralApp::Const.default_headers
        res = HTTParty.post(url, { headers: headers, body: body })
        if res.code != 200
          raise res
          #return false
        elsif res['data'] && res['data']['insert']
          ## Update ctr_product_id from the response
          res['data']['insert'].each do |row|
            product = Product.where(id: row['id']).first
            product.update_attributes(ctr_product_id: row['oid'])
            ## Update variants from skus
            if row['skus']
              row['skus'].each do |sku|
                pv = ProductVariant.where(id: sku['id']).first
                pv.update_attributes(ctr_sku_id: sku['oid'])
              end
            end
          end
        end
      rescue
        retry_count += 1
        if retry_count == CentralApp::Const::MAX_NUM_OF_ATTEMPTS
          Airbrake.notify({ error_message: "Failed to post to #{url}", parameters: {
              callback_setting_id: product_setting.id,
              body: body,
              response: res
          }})
          return false
        end
        if retry_count < CentralApp::Const::MAX_NUM_OF_ATTEMPTS && CentralApp::Utils::Token.get_token
          #sleep(CentralApp::Utils.sec_till_next_try(retry_count))
          retry
        end
      end
    end
    # Clear the sync queue after the job is done
    #SyncQueue.products.destroy_all
  end
end
