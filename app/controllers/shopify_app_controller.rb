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
    shop = request.params['shop']
store = Store.find_by(store_id: store_id) if store_id
    if shop
      session = ShopifyAPI::Session.new(domain: shop, api_version: '2020-07', token: nil)
      permission_url = session.create_permission_url(ShopifyApp::Const::SCOPE, "#{ShopifyApp::Const::APP_URL}/auth")
      redirect_to permission_url
    end
  end

  def welcome
    @shop = params[:shop]
    if @shop
      @api_key = ShopifyApp::Const::API_KEY
      @store = Store.find_by(source_url: @shop)
      @products = @store.products.where("ctr_product_id IS NOT NULL").where(available: true).order("created_at DESC").limit(100) if @store
      if @products.blank? && @store
        myshopify_domain = @store.source_url
        access_token = @store.source_token
        if myshopify_domain && access_token
          ShopifyApp::Utils.instantiate_session(myshopify_domain, access_token)
          # Call shopify API to fetch all product ids to check if user has posted product to our channel
          @product_ids = ShopifyAPI::ProductListing.product_ids
        end
      end
    else
      redirect_to err_page_shopify_app_index_path(msg: 'unauthorized')
    end
  end

  def auth
    #if ShopifyApp::Utils.valid_request_from_shopify?(request)
      # params['shop'] is shop's myshopify.com domain, which is unique identifier for each shopify store
      shop = request.params['shop']
      code = request.params['code']
      access_token = ShopifyApp::Utils.get_shop_access_token(shop, code)
      if access_token
        ShopifyApp::Utils.instantiate_session(shop, access_token)
        # Create a store for this shopify user if it does not exists in db
        store = ShopifyApp::Utils.persist_if_not_exists(shop, access_token)
        if store
          # Call the Scraper worker to fetch all products from the store upon the creation of a new store for shopify user
          ShopifyStoresScraperWorker.perform_async(store.id)
          # Fire ProductsSyncWorker immediately after the scraping is done
          ProductsSyncWorker.perform_async
          # Create webhooks for Shopify events/topics
          ShopifyWebhooksWorker.perform_async(store.id)

          redirect_to welcome_shopify_app_index_path(shop: shop) and return
        else
          redirect_to err_page_shopify_app_index_path(msg: 'Internal error: failed to persist store') and return
        end
      else
        redirect_to err_page_shopify_app_index_path(msg: 'Failed to get token from Shopify') and return
      end
    #end
    #redirect_to err_page_shopify_app_index_path(msg: 'unauthorized')
  end

  def err_page
    @err_msg = params[:msg]
    @err_msg = 'unknown error' unless @err_msg.present?
  end

end
