require 'shopify_app/webhook'

class Api::ProductsController < ApiController
  skip_before_action :authenticate_request, only: [:shopify_webhook]

  def query
    products = Feed::Api.search(params.reject{|_, v| v.blank?})
    hash = ProductSerializer.new(products).serializable_hash
    fields = params[:fields] ? params[:fields].split(',').map(&:strip).map(&:downcase) : []
    if fields.present?
      selected_hash = { data: [] }
      hash[:data].each do |product|
        selected_hash[:data] << product.select { |key, value| fields.include?(key.to_s.downcase) }
      end
      hash = selected_hash
    end
    render json: hash, status: :ok
  end

  def shopify_webhook
    # inspect hmac value in header and verify webhook
    hmac = request.env['HTTP_X_SHOPIFY_HMAC_SHA256']

    request.body.rewind
    data = request.body.read

    logger.warn "Domain: #{request.env['HTTP_X_SHOPIFY_SHOP_DOMAIN']}"
    logger.warn "Webhook: #{data}"
    if ShopifyApp::Utils.webhook_ok?(hmac, data)
      shop = request.env['HTTP_X_SHOPIFY_SHOP_DOMAIN']
      store = Store.find_by(source_url: shop)

      if store&.source_token
        topic = request.env['HTTP_X_SHOPIFY_TOPIC']
        logger.warn "Product Topic: #{topic}"
        if topic
          ShopifyApp::Utils.instantiate_session(shop, store.source_token)
          data_object = JSON.parse(data, object_class: OpenStruct)
          WebhookRequest.create(source: 'shopify', res: data_object, domain: shop, topic: topic)
          case topic
          when "app/uninstalled"
            ShopifyApp::Webhook.app_uninstalled(store)
          when "shop/update"
            ShopifyApp::Webhook.shop_update(data_object)
          when "product_listings/add", "product_listings/update"
            ShopifyApp::Webhook.product_listings_add_or_update(store, data_object)
          when "product_listings/remove"
            ShopifyApp::Webhook.product_listings_remove(data_object)
          else
            logger.warn "topic handler not found"
          end
        else
          logger.warn "header does not include topic"
          render json: {ec: 400, em: "topic not provided"}, status: :bad_request and return
        end
        render json: {msg: 'Webhook notification received successfully.'}, status: :ok and return
      end
    end
    render json: {ec: 403, em: "You're not authorized to perform this action."}, status: :forbidden
  end

end
