class Api::CallbackSettingsController < ApiController

  def callback
    ### 参数列表：
    setting_params.each do |key, value|
      url = value[:callback].strip rescue nil
      mode = value[:mode].strip
      bunch_size = value[:bunchsize].strip
      raise InvalidCallbackURL if url.empty?

      setting = CallbackSetting.where(callback_type: key.downcase).first_or_create
      # 更新CallbackSetting设置
      setting.url = url if url
      setting.mode = mode if mode
      setting.bunch_size = bunch_size if bunch_size
      setting.save
    end
    render json: {}, status: :ok
  rescue InvalidCallbackURL
    render json: { ec: 400, em: 'Invalid Callback URL' }, status: :bad_request
  end

  def delete_customer
    render json: {}, status: :ok
  end

  def delete_store
    render json: {}, status: :ok
  end

  private
  def setting_params
    params.require(:settings).permit!
  end

  class InvalidCallbackURL < StandardError; end
end
