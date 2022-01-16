Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  resources :users, only: [:create]
  put '/account', to: 'users#update'
  delete '/account', to: 'users#delete'
  post '/login', to: 'users#login'
  post '/deposit', to: 'users#deposit'
  delete '/reset', to: 'users#reset'

  resources :products, only: [:index, :show, :create, :update, :destroy]
  post '/buy', to: 'products#buy'
end
