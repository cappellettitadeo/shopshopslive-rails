Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  # API交互文档
  get 'docs' => 'docs#index'

  # 根据中心系统要求进行routes配置
  # RESTful规范的routes定义如下
  namespace :api do
    post 'setting/callback', to: 'callback_settings#callback'
    get 'product/query', to: 'products#query'
    get 'inventory/query', to: 'inventory#query'

    resources :products do
      collection do
        get :query
      end
    end
    resources :callback_settings do
    end
    resources :inventory do
    end
  end
end
