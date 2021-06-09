class Api::ApiKeysController < ApiController
  skip_before_action :authenticate_request

  def login
    key = ApiKey.find_by_name(params[:name])
    if key && key.valid_password?(params[:pwd])
      render json: { data: { token: key.auth_token } }, status: :ok
    else
      render json: { ec: 401, em: 'Not Authorized' }, status: 401
    end
  end

  # For testing purposes only
  def trigger_callback
    ProductsSyncWorker.perform_async
    render json: { msg: 'success' }, status: :ok
  end

  ### !!!!!!!!!!!!!!!
  # TODO Need to remove as soon as testing is done
  ### !!!!!!!!!!!!!!!
  def destroy_all
    Product.destroy_all
    Store.destroy_all
    Vendor.destroy_all
    SyncQueue.destroy_all
    render json: { msg: 'success' }, status: :ok
  end

  # For testing purposes only
  def trigger_inventory_callback
    # id 47 is the Blur-Dating store product variant
    if ProductVariant.last
      id = ProductVariant.last.id
      InventorySyncWorker.perform_async(id)
      render json: { msg: 'success' }, status: :ok
    else
      render json: { msg: 'No product and variant in the db' }, status: :ok
    end
  end
end
