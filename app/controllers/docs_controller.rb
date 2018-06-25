class DocsController < ApplicationController
  http_basic_authenticate_with name: 'shopshops', password: '123456'
  layout 'docs'

  def index
  end
end
