class Api::ProductsController < ApiController

  def query
    ### 参数列表：
    # ids - Return only certain products, specified by a comma-separated list of product IDs
    # limit - Return up to this many results per page. default: 50, max: 250
    # page - Return a specific page of results. default: 1
    # title - Filter results by product title.
    # vendor - Filter results by product vendor.
    # product_type - Filter results by product type.
    # category - Filter results by category.
    # created_at_min - Show products created after date. (format: 2014-04-25T16:15:47-04:00)
    # created_at_max - Show products created before date.
    # updated_at_min - Show products last updated after date.
    # updated_at_max - Show products last updated before date.
    # fields - Show only certain fields, specified by a comma-separated list of field names. By default, should reply with all fields.
    ###
    if true
      products = Feed::API.search(params)
      fields = params[:fields] ? params[:fields].split(',').map(&:strip) : []
      options = { fields: fields }
      hash = ProductSerializer.new(products, options).serializable_hash
      render json: hash, status: :ok
    else
      render json: { ec: 400, em: 'You must specify ids' }, status: :bad_request
    end
  end
end
