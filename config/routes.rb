Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # ATM Authentication routes
  get "login" => "sessions#new", as: :login
  post "login" => "sessions#create"
  delete "logout" => "sessions#destroy", as: :logout

  # ATM interface (to be created)
  get "atm" => "atm#index", as: :atm

  # Transaction history
  get "transactions" => "transactions#index", as: :transactions

  # Defines the root path route ("/") - ATM entry point
  root "sessions#new"

  # Very limited routes for customers - only show for backend reference
  resources :customers, only: [:show]
end
