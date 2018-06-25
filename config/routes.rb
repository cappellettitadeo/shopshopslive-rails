Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
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

  resources :shopify_app do
    collection do
      get :auth
      get :install
      get :unauthorized
      get :welcome
      post :app_uninstalled
      post :products_create
      post :products_update
      post :products_delete
      post :shop_update
    end
  end

end
