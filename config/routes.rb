Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  # 根据中心系统要求进行routes配置
  get 'product/query', to: 'products#query'
  post 'setting/callback', to: 'callback_settings#callback'

  # RESTful规范的routes定义如下
  namespace :api do
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
