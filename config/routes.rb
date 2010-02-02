ActionController::Routing::Routes.draw do |map|
  map.namespace(:authenticated_system) do |authenticated_system|
    authenticated_system.resource :session
    authenticated_system.login  'login', :controller => 'sessions', :action => 'new'
    authenticated_system.logout 'logout', :controller => 'sessions', :action => 'destroy'  
    authenticated_system.show_login 'show_login', :controller => 'sessions', :action => 'show'
    authenticated_system.open_id_login 'session', :controller => 'sessions', :action => 'create', :requirements => { :method => :get }
  end
      
  map.openid_create 'openid_create', :controller => 'users', :action => 'create', :requirements => { :method => :post }  
  map.openid_new 'openid_new', :controller => 'users', :action => 'openid_new'

  map.resources :people, :has_one => :user
  map.resources :permissions, :roles
end