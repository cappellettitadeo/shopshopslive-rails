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
end
