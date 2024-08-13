Rails.application.routes.draw do
  get 'tweets/new'
  get 'tweets/index'
  get 'tweets/show'
  get 'tweets/create'
  get 'users/index'
  get 'users/show'
  devise_for :users
  root 'home#top'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
