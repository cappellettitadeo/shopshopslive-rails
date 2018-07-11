require 'central_app'

class CallbackSettingsSyncWorker
  include Sidekiq::Worker
  include HTTParty

  sidekiq_options unique: true

  def perform
    CallbackSetting.sync_with_central_app
  end
end
