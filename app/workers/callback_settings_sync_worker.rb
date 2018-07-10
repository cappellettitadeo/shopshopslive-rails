require 'central_app'

class CallbackSettingsSyncWorker
  include Sidekiq::Worker
  include HTTParty

  sidekiq_options unique: true

  # TODO
  SETTING_URL = ''

  def perform
    parsed_json = CentralApp::Utils::Callback.list_all

    if parsed_json
      parsed_json.each do |key, value|
        url = value[:callback].strip rescue nil
        mode = value[:mode].strip
        bunch_size = value[:bunchsize]
        return if url.empty?

        setting = CallbackSetting.where(callback_type: key.downcase).first_or_create
        # 更新CallbackSetting设置
        setting.url = url
        setting.mode = mode if mode
        setting.bunch_size = bunch_size if bunch_size
        setting.save
      end
    end
  end
end
