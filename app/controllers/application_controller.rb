class ApplicationController < ActionController::Base
  after_action :allow_shopify_iframe
  protect_from_forgery

  private
  def allow_shopify_iframe
    response.headers['X-Frame-Options'] = 'ALLOWALL'
  end
end
