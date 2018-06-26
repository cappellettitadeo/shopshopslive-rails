class ProductsSyncWorker
  include Sidekiq::Worker

  sidekiq_options unique: true

  def perform
    setting = CallbackSetting.products.first
    # 如果mode不是"bunch"，则直接返回
    return unless setting && setting.bunch_update?

    SyncQueue.products.find_in_batches(batch_size: setting.bunch_size) do |items|
      products = items.collect(:target)
      products_hash = ProductSerializer.new(products).serializable_hash
      # POST to Center System
      if setting
        url = setting.url
        body = { products: products_hash }
        res = HTTParty.post(url, { body: body })
        return false if res.code != 200
      end
    end
  end
end
