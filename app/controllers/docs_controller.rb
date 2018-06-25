class DocsController < ApplicationController
  http_basic_authenticate_with name: 'shopshops', password: 'shopshops2018'
  layout 'docs'

  def index
  end
end
