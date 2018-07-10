class ProductsSyncWorker
  include Sidekiq::Worker

  sidekiq_options unique: true

  def perform
    product_setting = CallbackSetting.product.first
    vendor_setting = CallbackSetting.vendor.first
    store_setting = CallbackSetting.stores.first
    # 如果mode不是"bunch"，则直接返回
    return unless product_setting && product_setting.bunch_update?

    SyncQueue.products.find_in_batches(batch_size: product_setting.bunch_size) do |items|
      products = items.collect(&:target)
      ## 1. Find all unique vendors from these products
      vendors = products.collect(&:vendor).uniq
      # 1.1 Create/Update vendors to Central System
      url = vendor_setting.url
      vendors_hash = VendorSerializer.new(vendors).serializable_hash

      # 1.2 POST to Central System
      body = { count: vendors.count, brands: vendors_hash[:data] }
      headers = { token: 'eyJ0eXAiOiJqd3QiLCJhbGciOiJIUzI1NiJ9.eyJuYW1lIjoic2hvcHNob3BzIiwicHdkIjoiU2hvcHNob3BzMjAxOCIsImlzcyI6InNob3BzaG9wcyIsImV4cCI6MTUzMTE4NzI5MywiaWF0IjoxNTMxMTgwMDkzfQ.ytSqct0dYYY_c9G4wb6rlX8_7SvP-0MF0D8GbN5-X4g',
                  uid: '823cd75e7f9cb62a98b7989fa6a5fD', typ: 'JWT' }
      res = HTTParty.post(url, { headers: headers, body: body })
      if res.code != 200
        Airbrake.notify({ error_message: "Failed to post to #{url}", parameters: {
          callback_setting_id: vendor_setting.id,
          body: body,
          response: res
        }})
        return false
      else
        ## TODO Update ctr_vendor_id from the response
      end

      ## 2. Find all stores from these products
      stores = products.collect(&:store).uniq
      # 2.1 Create/Update stores to Central System
      url = store_setting.url
      stores_hash = StoreSerializer.new(stores).serializable_hash

      # 2.2 POST to Central System
      body = { count: stores.count, stores: stores_hash[:data] }
      res = HTTParty.post(url, { headers: headers, body: body })
      if res.code != 200
        Airbrake.notify({ error_message: "Failed to post to #{url}", parameters: {
          callback_setting_id: store_setting.id,
          body: body,
          response: res
        }})
        return false
      else
        ## TODO Update ctr_store_id from the response
      end

      ## 3. Create/Update products to Central System
      url = product_setting.url
      products_hash = ProductSerializer.new(products).serializable_hash
      body = { count: products.count, products: products_hash[:data] }
      res = HTTParty.post(url, { headers: headers, body: body })
      if res.code != 200
        Airbrake.notify({ error_message: "Failed to post to #{url}", parameters: {
          callback_setting_id: product_setting.id,
          body: body,
          response: res
        }})
        return false
      else
        ## TODO Update ctr_product_id from the response
      end
    end
    # Clear the sync queue after the job is done
    #SyncQueue.products.destroy_all
  end
end
