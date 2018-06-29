class Api::ProductsController < ApiController
  swagger_controller :products, "Products"

  swagger_api :query do
    summary "List all products"
    param :header, 'Authorization', :string, :required, '当前用户Auth token'
    param :query, :ids, :string, :optional, "Return only certain products, specified by a comma-separated list of product IDs."
    param :query, :page, :integer, :optional, "Return a specific page of results. default: 1"
    param :query, :limit, :integer, :optional, "Return up to this many results per page. default: 50, max: 250"
    param :query, :title, :string, :optional, "Filter results by product title."
    param :query, :vendor, :string, :optional, "Filter results by product vendor."
    param :query, :category, :string, :optional, "Filter results by category."
    #param :query, :product_type, :string, :optional, "Filter results by product type."
    param :query, :created_at_min, :string, :optional, "Show products created after date. (format: 2014-04-25T16:15:47-04:00)."
    param :query, :created_at_max, :string, :optional, "Show products created before date. (format: 2014-04-25T16:15:47-04:00)."
    param :query, :updated_at_min, :string, :optional, "Show products updated after date. (format: 2014-04-25T16:15:47-04:00)."
    param :query, :updated_at_max, :string, :optional, "Show products updated before date. (format: 2014-04-25T16:15:47-04:00)."
    param :query, :fields, :string, :optional, "Show only certain fields, specified by a comma-separated list of field names. By default, should reply with all fields."

    response :bad_request
    response :ok
  end

  def query
    products = Feed::Api.search(params)
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
end
