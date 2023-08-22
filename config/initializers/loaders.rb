ActiveSupport.on_load(:action_controller) do
  require 'authenticated_system/extensions/action_controller_ext'
  include AuthenticatedSystem::Extension::ActionController
end
# ActionView::Base.send :include, AclHelper
