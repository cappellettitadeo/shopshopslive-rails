class ProductsSyncWorker
  include Sidekiq::Worker

  sidekiq_options unique: true

  def perform
    product_setting = CallbackSetting.product.first
    vendor_setting = CallbackSetting.vendor.first
    store_setting = CallbackSetting.store.first
    # 如果mode不是"bunch"，则直接返回
    return unless product_setting && product_setting.bunch_update?

    SyncQueue.products.find_in_batches(batch_size: product_setting.bunch_size) do |items|
      products = items.collect(:target)
      ## 1. Find all unique vendors from these products
      vendors = products.collect(&:vendor).uniq
      # 1.1 Create/Update vendors to Central System
      url = vendor_setting.url
      vendors_hash = VendorSerializer.new(vendors).serializable_hash
      # 1.2 Set action type base on ctr_store_id
      vendors_hash[:action] = vendors_hash[:ctr_vendor_id] ? 'update' : 'create'

      # 1.3 POST to Central System
      body = { count: vendors.count, brands: vendors_hash }
      res = HTTParty.post(url, { body: body })
      ## TODO Update ctr_vendor_id from the response
      return false if res.code != 200

      ## 2. Find all stores from these products
      stores = products.collect(&:store).uniq
      products_hash = ProductSerializer.new(products).serializable_hash
      # 2.1 Create/Update stores to Central System
      url = store_setting.url
      stores_hash = StoreSerializer.new(stores).serializable_hash
      # 2.2 Set action type base on ctr_store_id
      vendors_hash[:action] = vendors_hash[:ctr_store_id] ? 'update' : 'create'

      # 2.3 POST to Central System
      body = { count: stores.count, vendors: stores_hash }
      res = HTTParty.post(url, { body: body })
      ## TODO Update ctr_store_id from the response
      return false if res.code != 200

      ## 3. Create/Update products to Central System
      url = product_setting.url
      # 3.1 Set action type base on ctr_product_id
      vendors_hash[:action] = vendors_hash[:ctr_store_id] ? 'update' : 'create'
      body = { products: products_hash }
      res = HTTParty.post(url, { body: body })
      return false if res.code != 200
    end
  end
end
