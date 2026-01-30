require "sidekiq/web"

Rails.application.routes.draw do
  mount Sidekiq::Web => "/sidekiq"

  namespace :api do
    namespace :v1 do
      resources :products
      resource :cart, only: [:create, :show] do
        member do
          put :add_item, to: "carts#update"
          delete "/:product_id", to: "carts#destroy"
        end
      end
    end
  end

  get "up" => "rails/health#show", :as => :rails_health_check
  root "rails/health#show"
end
