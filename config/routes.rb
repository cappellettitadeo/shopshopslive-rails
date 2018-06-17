Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  namespace :api do
    resources :products do
      collection do
        get :query
        get :hi
      end
    end
    resources :callback_settings do
    end
    resources :inventory do
    end

    resources :shopify_app do
      collection do
        get :hi
      end
    end
  end
end
