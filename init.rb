# Include hook code here
# I18n.load_path += Dir[File.join(File.dirname(__FILE__), 'config', 'locales', '**', '*.yml')]

ActionView::Base.send :include, AclHelper
ActionController::Base.send :include, AuthenticatedSystem