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
    scope = %w(read_orders, read_products)
    permission_url = session.create_permission_url(scope, "#{APP_URL}/shopify_app/auth")
    logger.debug permission_url
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
      render 'welcome'
    else
      render 'unauthorized'
    end
  end

  def unauthorized
  end

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
        logger.debug @tokens



      else
        return [500, "Something went wrong."]
      end

      get_products_url = "https://#{shop}/admin/products.json"
      instantiate_session(shop)
      get_products_response = HTTParty.get(get_products_url, headers: {
          "Content-type" => "application/json",
          'X-Shopify-Access-Token'=> @tokens[shop]
      })
      if get_products_response.code == 200
        collects = get_products_response['products']
        logger.debug collects
      end

    end
  end

  def instantiate_session(shop)
    # now that the token is available, instantiate a session
    session = ShopifyAPI::Session.new(shop, @tokens[shop])
    ShopifyAPI::Base.activate_session(session)
    shop = ShopifyAPI::Shop.current
    logger.debug shop
  end


end
