require 'central_app'

class OrdersSyncWorker
  include Sidekiq::Worker

  sidekiq_options unique: true, retry: 3

  def perform
    orders = Order.unsynced
    orders.each do |o|
      object = OpenStruct.new(o.fulfill_obj)
      o.sync_with_central_system(object)
    end
  end
end
