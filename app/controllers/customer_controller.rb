class CustomerController < ApplicationController
	def redact_customer
    render status: 200, json: {}
  end

  def redact_shop
    render status: 200, json: {}
  end

  def data_request
    render status: 200, json: {}
  end
end
