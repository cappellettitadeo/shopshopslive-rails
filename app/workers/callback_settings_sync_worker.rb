class CallbackSettingssSyncWorker
  include Sidekiq::Worker
  include HTTParty

  sidekiq_options unique: true

  # TODO
  SETTING_URL = ''

  def perform
    res = HTTParty.get(SETTING_URL)
    parsed_json = JSON.parse res

    if res.code == 200
      parsed_json.each do |key, value|
        url = value[:callback].strip rescue nil
        mode = value[:mode].strip
        bunch_size = value[:bunchsize].strip
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
