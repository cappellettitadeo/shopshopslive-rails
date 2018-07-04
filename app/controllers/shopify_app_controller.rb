require 'shopify_app'
require 'ostruct'

class ShopifyAppController < ApplicationController
  respond_to :json


  def initialize
    super
    ShopifyAPI::Session.setup(api_key: ShopifyApp::Const::API_KEY, secret: ShopifyApp::Const::API_SECRET)
  end

  def index
    redirect_to action: 'install'
  end

  def install
    session = ShopifyAPI::Session.new(request.params['shop'])
    permission_url = session.create_permission_url(ShopifyApp::Const::SCOPE, "#{ShopifyApp::Const::APP_URL}/auth")
    logger.debug permission_url
    redirect_to permission_url
  end

  def welcome
    unless ShopifyApp::Utils.valid_request_from_shopify?(request)
      render 'unauthorized'
    end
  end

  def auth
    if ShopifyApp::Utils.valid_request_from_shopify?(request)
      #param shop is actually shop's myshopify.com domain, which is unique identifier for each shopify store
      shop = request.params['shop']
      code = request.params['code']
      access_token = ShopifyApp::Utils.get_shop_access_token(shop, code)
      ShopifyApp::Utils.instantiate_session(shop, access_token)
      #create a store for this shopify user if it does not exists in db
      store = ShopifyApp::Utils.persist_if_not_exists(shop, access_token)
      #call the Scraper worker to fetch all products from the store upon the creation of a new store for shopify user
      ShopifyStoresScraperWorker.new.perform(store.id) if store

      ShopifyApp::Utils.create_webhooks

      render 'welcome'
    else
      render 'unauthorized'
    end
  end

  def unauthorized
  end

end
