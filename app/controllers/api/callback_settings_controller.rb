class Api::CallbackSettingsController < ApiController

  swagger_controller :callback_settings, "回调配置"

  swagger_api :callback do
    summary "设置回调URL与模式"
    param :header, 'Authorization', :string, :required, '当前用户auth token'
    param :form, :'settings[product]', :Product, :optional, '产品回调配置'
    param :form, :'settings[inventory]', :Inventory, :optional, '库存回调配置'
    param :form, :'settings[store]', :Store, :optional, '商家回调配置'
    param :form, :'settings[vendor]', :Vendor, :optional, '品牌回调配置'

    response :bad_request
    response :ok
  end

  swagger_model :Product do
    description '产品回调配置'
    property :callback, :string, :required, '回调URL'
    property :mode, :string, :optional, '工作模式：immediate: 一有商品更新就立刻进行回调, bunch: 批量进行商品回调，此模式需要设置bunchsize'
    property :bunchsize, :string, :optional, '用于指定每次商品批量更新的尺寸'
  end

  swagger_model :Inventory do
    description '库存回调配置'
    property :callback, :string, :required, '回调URL'
    property :mode, :string, :optional, '工作模式：immediate: 一有商品更新就立刻进行回调, bunch: 批量进行商品回调，此模式需要设置bunchsize'
    property :bunchsize, :string, :optional, '用于指定每次商品批量更新的尺寸'
  end

  swagger_model :Store do
    description '商家回调配置'
    property :callback, :string, :required, '回调URL'
    property :mode, :string, :optional, '工作模式：immediate: 一有商品更新就立刻进行回调, bunch: 批量进行商品回调，此模式需要设置bunchsize'
    property :bunchsize, :string, :optional, '用于指定每次商品批量更新的尺寸'
  end

  swagger_model :Vendor do
    description '品牌回调配置'
    property :callback, :string, :required, '回调URL'
    property :mode, :string, :optional, '工作模式：immediate: 一有商品更新就立刻进行回调, bunch: 批量进行商品回调，此模式需要设置bunchsize'
    property :bunchsize, :string, :optional, '用于指定每次商品批量更新的尺寸'
  end

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


  private
  def setting_params
    params.require(:settings).permit!
  end

  class InvalidCallbackURL < StandardError; end
end
