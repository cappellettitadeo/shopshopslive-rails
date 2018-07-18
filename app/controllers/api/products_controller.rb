require 'shopify_app/webhook'

class Api::ProductsController < ApiController
  skip_before_action :authenticate_request, only: [:shopify_webhook]
  swagger_controller :products, "商品管理"

  swagger_api :query do
    summary "商品查询接口"
    param :header, 'Authorization', :string, :required, '当前用户Auth token'
    param :query, :ids, :string, :optional, "Return only certain products, specified by a comma-separated list of product IDs."
    param :query, :page, :integer, :optional, "Return a specific page of results. default: 1"
    param :query, :limit, :integer, :optional, "Return up to this many results per page. default: 50, max: 250"
    param :query, :title, :string, :optional, "Filter results by product title."
    param :query, :vendor, :string, :optional, "Filter results by product vendor."
    param :query, :category, :string, :optional, "Filter results by category."
    param :query, :created_at_min, :string, :optional, "Show products created after date. (format: 2014-04-25T16:15:47-04:00)."
    param :query, :created_at_max, :string, :optional, "Show products created before date. (format: 2014-04-25T16:15:47-04:00)."
    param :query, :updated_at_min, :string, :optional, "Show products updated after date. (format: 2014-04-25T16:15:47-04:00)."
    param :query, :updated_at_max, :string, :optional, "Show products updated before date. (format: 2014-04-25T16:15:47-04:00)."
    param :query, :fields, :string, :optional, "Show only certain fields, specified by a comma-separated list of field names. By default, should reply with all fields."

    response :bad_request
    response :ok
  end

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

    if ShopifyApp::Utils.webhook_ok?(hmac, data)
      shop = request.env['HTTP_X_SHOPIFY_SHOP_DOMAIN']
      store = Store.find_by(source_url: shop)

      if store&.source_token
        topic = request.env['HTTP_X_SHOPIFY_TOPIC']
        if topic
          ShopifyApp::Utils.instantiate_session(shop, store.source_token)
          data_object = JSON.parse(data, object_class: OpenStruct)
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
