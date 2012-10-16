Rails.application.routes.draw do

  mount AuthenticatedSystem::Engine => "/authenticated_system"
end
