# 为了在Rails API使用Swagger Gem，需要提前设置base_api_controller
Swagger::Docs::Config.base_api_controller = ActionController::API
include Swagger::Docs::ImpotentMethods

Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  # API交互文档
  get 'docs' => 'docs#index'
  root to: redirect('/docs')

  namespace :api do
    # 根据中心系统要求进行routes配置
    post 'setting/callback', to: 'callback_settings#callback'
    get 'product/query', to: 'products#query'
    get 'inventory/query', to: 'inventory#query'

    # RESTful规范的routes定义如下
    resources :products do
      collection do
        get :query
      end
    end
    resources :callback_settings do
      collection do
        post :callback
      end
    end
    resources :inventory do
    end
  end
end
