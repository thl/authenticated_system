# == Schema Information
# Schema version: 20090626173648
#
# Table name: permissions
#
#  id          :integer(4)      not null, primary key
#  title       :string(60)      not null
#  description :text
#
module AuthenticatedSystem  
  class Permission < ActiveRecord::Base
    before_destroy { |record| record.roles.clear }
    has_and_belongs_to_many :roles

    # Ensure that the table has one entry for each controller/action pair
    def self.synchronize_with_controllers
      # This no longer seems to be necessary: (either way they do show up in production and don't in development)
      # Rails.configuration.paths.app.controllers.paths.each { |controller_path| Dir.foreach(controller_path) { |file_name| require(File.join(controller_path, file_name)) if /_controller.rb$/ =~ file_name && file_name != 'acl_controller.rb' } if File.exist?(controller_path) }
      all_actions = AclController.descendants.collect do |klass|
        controller_path = klass.controller_path
        klass.action_methods.reject{|a| a=~/_callback/ || a.ends_with?('_url') || a.ends_with?('_path')}.collect { |method| "#{controller_path}/#{method.to_s}" }
      end.flatten
      known_actions = self.all.collect(&:title)
      bogus_db_actions = known_actions - all_actions
      missing_from_db = all_actions - known_actions
      missing_from_db.each { |action_path| self.create :title => action_path }
      self.where(title: bogus_db_actions).destroy_all unless bogus_db_actions.empty? || all_actions.empty? || bogus_db_actions.length > all_actions.length / 2
    end
  end
end
