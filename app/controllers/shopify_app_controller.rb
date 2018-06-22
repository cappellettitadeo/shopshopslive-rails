require 'httparty'
require 'dotenv/load'

class ShopifyAppController < ApplicationController
  respond_to :json

  attr_reader :tokens
  API_KEY = ENV['API_KEY']
  API_SECRET = ENV['API_SECRET']
  APP_URL = "https://shopsshops.fwd.wf"

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
    unless valid_request_from_shopify?(request)
      render 'unauthorized'
    end
  end

  def auth
    if valid_request_from_shopify?(request)
      shop = request.params['shop']
      code = request.params['code']
      get_shop_access_token(shop,API_KEY,API_SECRET,code)
      save_shop
      save_products
      create_products_webhooks
      #save_inventory_items
      render 'welcome'
    else
      render 'unauthorized'
    end
  end

  def unauthorized
  end

  def product_create
    # inspect hmac value in header and verify webhook
    hmac = request.env['HTTP_X_SHOPIFY_HMAC_SHA256']

    request.body.rewind
    data = request.body.read
    webhook_ok = verify_webhook(hmac, data)

    if webhook_ok
      shop = request.env['HTTP_X_SHOPIFY_SHOP_DOMAIN']
      token = @tokens[shop]

      if not token.nil?
        session = ShopifyAPI::Session.new(shop, token)
        ShopifyAPI::Base.activate_session(session)
      else
        return [403, "You're not authorized to perform this action."]
      end
    else
      return [403, "You're not authorized to perform this action."]
    end

    # parse the request body as JSON data
    json_data = JSON.parse data
    logger.debug json_data

    line_items = json_data['line_items']

    line_items.each do |line_item|
      variant_id = line_item['variant_id']

      variant = ShopifyAPI::Variant.find(variant_id)

      variant.metafields.each do |field|
        if field.key == 'ingredients'
          items = field.value.split(',')

          items.each do |item|
            gift_item = ShopifyAPI::Variant.find(item)
            gift_item.inventory_quantity = gift_item.inventory_quantity - 1
            gift_item.save
          end
        end
      end
    end

    return [200, "Webhook notification received successfully."]

  end

  #some helper methods
  private
  def valid_request_from_shopify?(request)
    hmac = request.params['hmac']
    if not hmac.nil?
      hash = request.params.reject{|k,_| k == 'hmac' || k == 'controller' || k == 'action' }
      query = URI.escape(hash.sort.collect{|k,v| "#{k}=#{v}"}.join('&'))
      digest = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), API_SECRET, query)

      ActiveSupport::SecurityUtils.secure_compare(hmac, digest)
    else
      false
    end
  end

  def get_shop_access_token(shop,client_id,client_secret,code)
    if @tokens[shop].nil?
      url = "https://#{shop}/admin/oauth/access_token"

      payload = {
          client_id: client_id,
          client_secret: client_secret,
          code: code}

      response = HTTParty.post(url, body: payload)
      # if the response is successful, obtain the token and store it in a hash
      if response.code == 200
        @tokens[shop] = response['access_token']
      else
        return [500, "Something went wrong."]
      end

      instantiate_session(shop)
    end
  end

  def instantiate_session(shop)
    # now that the token is available, instantiate a session
    session = ShopifyAPI::Session.new(shop, @tokens[shop])
    ShopifyAPI::Base.activate_session(session)
  end

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

  def create_products_webhooks
    create_products_create_webhook
  end

  def create_products_create_webhook
    unless ShopifyAPI::Webhook.find(:all, :params => {:topic => 'products/create'}).nil?
      webhook = {
          topic: 'products/create',
          address: "#{APP_URL}/shopify_app/product_create",
          format: 'json'
      }
      ShopifyAPI::Webhook.create(webhook)
    end
  end


end
