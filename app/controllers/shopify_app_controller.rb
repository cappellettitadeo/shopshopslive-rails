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

  def shopify_webhook
    # inspect hmac value in header and verify webhook
    hmac = request.env['HTTP_X_SHOPIFY_HMAC_SHA256']

    request.body.rewind
    data = request.body.read

    if ShopifyApp::Utils.webhook_ok?(hmac, data)
      shop = request.env['HTTP_X_SHOPIFY_SHOP_DOMAIN']
      store = Store.find_by(source_url: shop)

      if store.present? && store.source_token
        topic = request.env['HTTP_X_SHOPIFY_TOPIC']
        if topic
          ShopifyApp::Utils.instantiate_session(shop, store.source_token)
          data_object = JSON.parse(data, object_class: OpenStruct)
          case topic
          when "app/uninstalled"
            ShopifyApp::Webhook.app_uninstalled(data_object)
          when "shop/update"
            ShopifyApp::Webhook.shop_update(data_object)
          when "products/create"
            ShopifyApp::Webhook.products_create(store, data_object)
          when "products/delete"
            ShopifyApp::Webhook.products_delete(data_object)
          when "products/update"
            ShopifyApp::Webhook.products_update(data_object)
          else
            logger.warn "topic handler not found"
          end
        else
          logger.warn "header does not include topic"
        end
      else
        render json: {ec: 403, em: "You're not authorized to perform this action."}, status: :forbidden
      end
    else
      render json: {ec: 403, em: "You're not authorized to perform this action."}, status: :forbidden
    end

    render json: {ec: 200, em: 'Webhook notification received successfully.'}, status: :ok
  end

end
