require 'sidekiq/web'

Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'

  namespace :api do
    namespace :v1 do
      resources :products
      resource :cart, only: [:create, :show, :update, :destroy] do
        member do
          post :add_item
        end
      end
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
  root "rails/health#show"
end
