$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "authenticated_system/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "authenticated_system"
  s.version     = AuthenticatedSystem::VERSION
  s.authors     = ["Andres Montano"]
  s.email       = ["amontano@virginia.edu"]
  s.homepage    = "http://subjects.kmaps.virginia.edu"
  s.summary     = "Provides login support, roles and permissions at a controller / action level."
  s.description = "Provides login support, roles and permissions at a controller / action level."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency 'rails'
  # s.add_dependency "jquery-rails"
  s.add_dependency 'bcrypt', '~> 3.1'
end
