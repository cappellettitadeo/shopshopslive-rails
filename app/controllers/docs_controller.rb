class DocsController < ApplicationController
  http_basic_authenticate_with name: 'shopshops', password: 'PQL4QY4juqGD9m'
  layout 'docs'

  def index
  end
end
