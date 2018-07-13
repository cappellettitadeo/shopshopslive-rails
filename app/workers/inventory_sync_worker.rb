require 'central_app'

class InventorySyncWorker
  include Sidekiq::Worker

  sidekiq_options unique: true

  def perform(variant_id)
    inventory_setting = CallbackSetting.inventory.first
    # 如果mode不是"bunch"，则直接返回
    return unless inventory_setting &.bunch_update?

    variant = ProductVariant.find variant_id
    product = variant.product
    if variant&.ctr_sku_id && product&.ctr_product_id && product.vendor.ctr_vendor_id
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
