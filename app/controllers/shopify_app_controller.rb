require 'shopify_app'

class ShopifyAppController < ApplicationController
  respond_to :json

  attr_reader :tokens

  def initialize
    @tokens = {}
    ShopifyAPI::Session.setup(api_key: ShopifyApp::Const::API_KEY, secret: ShopifyApp::Const::API_SECRET)
    super
  end

  def index
    redirect_to action: 'install'
  end

  def install
    session = ShopifyAPI::Session.new(request.params['shop'])
    scope = %w(read_orders read_products read_inventory)
    permission_url = session.create_permission_url(scope, "#{ShopifyApp::Const::APP_URL}/auth")
    redirect_to permission_url
  end

  def welcome
    unless ShopifyApp::Utils.valid_request_from_shopify?(request)
      render 'unauthorized'
    end
  end

  def auth
    if ShopifyApp::Utils.valid_request_from_shopify?(request)
      shop = request.params['shop']
      code = request.params['code']
      @tokens[shop] = ShopifyApp::Utils.get_shop_access_token(shop, ShopifyApp::Const::API_KEY, ShopifyApp::Const::API_SECRET, code)
      ShopifyApp::Utils.instantiate_session(shop, @tokens[shop])
      ShopifyApp::Utils.create_new_store(@tokens[shop])
      ShopifyApp::Utils.create_webhooks
      render 'welcome'
    else
      render 'unauthorized'
    end
  end

  def unauthorized
  end

  def app_uninstalled

  end

  def products_create
    # inspect hmac value in header and verify webhook
    hmac = request.env['HTTP_X_SHOPIFY_HMAC_SHA256']

    request.body.rewind
    data = request.body.read

    if ShopifyApp::Utils.webhook_ok?(hmac, data)
      shop = request.env['HTTP_X_SHOPIFY_SHOP_DOMAIN']
      token = @tokens[shop]

      if not token.nil?
        session = ShopifyAPI::Session.new(shop, token)
        ShopifyAPI::Base.activate_session(session)
      else
        render json: {ec: 403, em: "You're not authorized to perform this action."}, status: unauthorized
      end
    else
      render json: {ec: 403, em: "You're not authorized to perform this action."}, status: unauthorized
    end

    # parse the request body as JSON data
    json_data = JSON.parse data
    logger.debug json_data

    render json: {status: 'Webhook notification received successfully.'}, status: :ok
  end

  def products_update

  end

  def products_delete

  end

  def shop_update

  end

end
