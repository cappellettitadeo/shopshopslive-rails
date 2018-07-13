require 'central_app'

class InventorySyncWorker
  include Sidekiq::Worker

  sidekiq_options unique: true

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
      body = { count: vendors.count, brands: vendors_hash[:data] }
      retries = CentralApp::Const::MAX_NUM_OF_ATTEMPTS
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
        retries -= 1
        if retries == 0
          Airbrake.notify({ error_message: "Failed to post to #{url}", parameters: {
              callback_setting_id: vendor_setting.id,
              body: body,
              response: res
          }})
        end
        retry if retries > 0 && CentralApp::Utils::Token.get_token
      end
    end
  end
end
