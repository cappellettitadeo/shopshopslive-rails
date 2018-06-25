require 'httparty'
require 'dotenv/load'
require 'shopify_app'

class ShopifyAppController < ApplicationController
  respond_to :json

  attr_reader :tokens
  API_KEY = ENV['API_KEY']
  API_SECRET = ENV['API_SECRET']
  APP_URL = ENV['APP_URL']

  def initialize
    @tokens = {}
    ShopifyAPI::Session.setup(api_key: API_KEY, secret: API_SECRET)
    super
  end

  def index
    redirect_to action: 'install'
  end

  def install
    session = ShopifyAPI::Session.new(request.params['shop'])
    scope = %w(read_orders, read_products, read_inventory)
    permission_url = session.create_permission_url(scope, "#{APP_URL}/shopify_app/auth")
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
      @tokens[shop] = ShopifyApp::Utils.get_shop_access_token(shop,API_KEY,API_SECRET,code)
      ShopifyApp::Utils.instantiate_session(shop, @tokens[shop])
      save_shop
      save_products
      ShopifyApp::Utils.create_webhooks
      #save_inventory_items
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

    if webhook_ok?(hmac, data)
      shop = request.env['HTTP_X_SHOPIFY_SHOP_DOMAIN']
      token = @tokens[shop]

      if not token.nil?
        session = ShopifyAPI::Session.new(shop, token)
        ShopifyAPI::Base.activate_session(session)
      else
        [403, "You're not authorized to perform this action."]
      end
    else
      [403, "You're not authorized to perform this action."]
    end

    # parse the request body as JSON data
    json_data = JSON.parse data
    logger.debug json_data

    [200, "Webhook notification received successfully."]
  end

  def products_update

  end

  def products_delete

  end

  def shop_update

  end

  #some helper methods
  private

  def save_shop
    shop = ShopifyAPI::Shop.current
    #logger.debug shop.domain
  end

  def save_products
    all_products = ShopifyAPI::Product.find(:all)
    logger.debug all_products
  end

  def save_inventory_items
    inventory_item = ShopifyAPI::InventoryItem.find(1087668256825)
    logger.debug inventory_item
  end

  def webhook_ok?(hmac, data)
    digest = OpenSSL::Digest.new('sha256')
    calculated_hmac = Base64.encode64(OpenSSL::HMAC.digest(digest, API_SECRET, data)).strip

    ActiveSupport::SecurityUtils.secure_compare(hmac, calculated_hmac)
  end


end
