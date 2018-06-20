class ProductsSyncWorker
  include Sidekiq::Worker

  sidekiq_options unique: true

  def perform
    SyncQueue.products.find_in_batches(batch_size: 20) do |items|
      products = items.collect(:target)
      products_hash = ProductSerializer.new(products).serializable_hash
      setting = CallbackSetting.products.first
      # POST to Center System
      if setting
      end
    end
  end
end
