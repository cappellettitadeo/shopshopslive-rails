require 'central_app'
class CentralAppSyncWorker
  include Sidekiq::Worker

  sidekiq_options unique: true

  def perform
    Category.sync_with_central_app
  end
end
