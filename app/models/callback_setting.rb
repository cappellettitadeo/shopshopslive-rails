class CallbackSetting < ApplicationRecord
  scope :product, -> { where(callback_type: 'product') }
  scope :stores, -> { where(callback_type: 'store') }
  scope :vendor, -> { where(callback_type: 'vendor') }

  def self.sync_with_central_app
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

  def bunch_update?
    mode == 'bunch'
  end

  def immediate_update?
    mode == 'immediate'
  end
end
