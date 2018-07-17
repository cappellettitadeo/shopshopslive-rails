require 'shopify_app'
require 'ostruct'

class ShopifyAppController < ApplicationController
  respond_to :json


  def initialize
    super
    ShopifyAPI::Session.setup(api_key: ShopifyApp::Const::API_KEY, secret: ShopifyApp::Const::API_SECRET)
  end

  def index
  end

  def install
    session = ShopifyAPI::Session.new(request.params['shop'])
    permission_url = session.create_permission_url(ShopifyApp::Const::SCOPE, "#{ShopifyApp::Const::APP_URL}/auth")
    redirect_to permission_url
  end

  def welcome
    @shop = params[:shop]
    if @shop
      @api_key = ShopifyApp::Const::API_KEY
      @store = Store.find_by(source_url: @shop)
      @products = @store.products.where(available: true) if @store
    else
      render 'unauthorized'
    end
  end

  def auth
    if ShopifyApp::Utils.valid_request_from_shopify?(request)
      # params['shop'] is shop's myshopify.com domain, which is unique identifier for each shopify store
      shop = request.params['shop']
      code = request.params['code']
      timestamp =request.params['timestamp']
      hmac = request.params['hmac']
      access_token = ShopifyApp::Utils.get_shop_access_token(shop, code)
      if access_token
        ShopifyApp::Utils.instantiate_session(shop, access_token)
        # Create a store for this shopify user if it does not exists in db
        store = ShopifyApp::Utils.persist_if_not_exists(shop, access_token)
        if store
          # Call the Scraper worker to fetch all products from the store upon the creation of a new store for shopify user
          ShopifyStoresScraperWorker.new.perform(store.id)
          # Fire ProductsSyncWorker immediately after the scraping is done
          ProductsSyncWorker.new.perform
        end

        ShopifyApp::Utils.create_webhooks

        redirect_to welcome_shopify_app_index_path(code: code, shop: shop, hmac: hmac, timestamp: timestamp)
        return
      end
    end
    render 'unauthorized'
  end

  def unauthorized
  end

end
