Rails.application.routes.draw do
  namespace :authenticated_system do
    get 'login', to: 'sessions#new', as: :login
    get 'logout', to: 'sessions#destroy', as: :logout
    get 'show_login', to: 'sessions#show', as: :show_login
    get 'session', to: 'sessions#create', as: :open_id_login
    resource :session
    resources :people do
      resource :user
    end
    root to: 'admin#index'
    resources :permissions, :roles
    post 'openid_create', to: 'users#create', as: :openid_create
    get 'openid_new', to: 'users#openid_new', as: :openid_new
  end
  get 'shibboleth', to: 'authenticated_system/sessions#shibboleth', constraints: { protocol: 'https://' }, as: :shibboleth
end