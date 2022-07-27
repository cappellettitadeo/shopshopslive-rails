class ApplicationController < ActionController::Base
  after_action :allow_shopify_iframe
  protect_from_forgery
  before_action :content_security_headers

  private
  def allow_shopify_iframe
    response.headers['X-Frame-Options'] = 'ALLOWALL'
  end

  def content_security_headers
    response.headers['Content-Security-Policy'] = current_domain_header
  end

  def current_domain_header
    current_domain ||= (params[:shop] || session[:shopify_domain])
    session[:shopify_domain] = params[:shop] unless session[:shopify_domain].present?

    "frame-ancestors https://#{current_domain} https://admin.shopify.com"
  end
end
