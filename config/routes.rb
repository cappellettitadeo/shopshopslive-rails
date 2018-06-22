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
      post :product_create
    end
  end

end
