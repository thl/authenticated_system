module AuthenticatedSystem
  class Engine < ::Rails::Engine
    initializer :assets do |config|
      Rails.application.config.assets.precompile << 'authenticated_system/select.js'
    end
  end
end
