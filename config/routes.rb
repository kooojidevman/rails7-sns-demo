Rails.application.routes.draw do

  devise_for :users
  root 'home#top'
  resources :tweets  # 追加
  resources :users  # 追加
end
