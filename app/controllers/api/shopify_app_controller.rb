class Api::ShopifyAppController < ApplicationController
  respond_to :json

  def hi
    render json: {msg: hi}, status: :ok
  end
end
