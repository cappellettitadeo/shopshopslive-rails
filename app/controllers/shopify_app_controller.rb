require 'shopify_app'

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
      #call the Scraper worker to fetch all products from the store upon the creation of a new store for shopify user
      ShopifyStoresScraperWorker.perform_async if ShopifyApp::Utils.persist_if_not_exists(shop, access_token)
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
      logger.debug 'webhook ok.'
      store = Store.find_by(source_url: shop)

      if store.present? && !store.source_token.nil?
        ShopifyApp::Utils.instantiate_session(shop, store.source_token)
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
    logger.debug 'product updated.'
  end

  def products_delete
    logger.debug 'product deleted'
  end

  def shop_update

  end

end
