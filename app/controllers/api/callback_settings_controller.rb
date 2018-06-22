class Api::CallbackSettingsController < ApiController

  def callback
    ### 参数列表：
    # callback(必填) - 用于 push 商品信息的回调接口, 例如: http://intermodu.shopshops.com.cn/product/callback
    # mode - 用于指定边缘系统的两种工作模式, immediate: 一有商品更新就立刻进行回调, bunch: 批量进行商品回调，此模式需要设置bunchsize
    # bunchsize - 用于指定每次商品批量更新的尺寸
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


  private
  def setting_params
    params.require(:settings).permit!
  end

  class InvalidCallbackURL < StandardError; end
end
