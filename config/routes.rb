Rails.application.routes.draw do
  namespace :authenticated_system do
    get 'login', to: 'sessions#new', as: :login
    get 'logout', to: 'sessions#destroy', as: :logout
    get 'show_login', to: 'sessions#show', as: :show_login
    resource :session
    resources :people do
      resource :user
    end
    root to: 'admin#index'
    resources :permissions, :roles
  end
  get 'shibboleth', to: 'authenticated_system/sessions#shibboleth', constraints: { protocol: 'https://' }, as: :shibboleth
end