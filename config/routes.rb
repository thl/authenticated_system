Rails.application.routes.draw do
  namespace :authenticated_system do
      resource :session
      match 'login' => 'sessions#new', :as => :login
      match 'logout' => 'sessions#destroy', :as => :logout
      match 'show_login' => 'sessions#show', :as => :show_login
      match 'session' => 'sessions#create', :as => :open_id_login, :via => :get
  end
  match 'openid_create' => 'users#create', :as => :openid_create, :via => :post
  match 'openid_new' => 'users#openid_new', :as => :openid_new
  resources :people do
    resource :user
  end
  resources :permissions, :roles
end