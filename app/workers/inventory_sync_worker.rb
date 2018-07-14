require 'central_app'

class InventorySyncWorker
  include Sidekiq::Worker

  sidekiq_options unique: true

  def perform(variant_id)
    inventory_setting = CallbackSetting.inventory.first
    variant = ProductVariant.find variant_id
    product = variant.product
    if inventory_setting && variant&.ctr_sku_id && product&.ctr_product_id && product.vendor.ctr_vendor_id
      url = inventory_setting.url
      variant_hash = {
        count: 1,
        inventories: [
          {
            prod_id: product.ctr_product_id,
            sku_id: variant.ctr_sku_id,
            inventory: variant.inventory,
            vendor: product.vendor.ctr_vendor_id
          }
        ]
      }

      # 1.2 POST to Central System
      body = variant_hash.to_json
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
              callback_setting_id: inventory_setting.id,
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
  end
end
