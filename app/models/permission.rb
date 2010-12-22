# == Schema Information
# Schema version: 20090626173648
#
# Table name: permissions
#
#  id          :integer(4)      not null, primary key
#  title       :string(60)      not null
#  description :text
#

class Permission < ActiveRecord::Base
  has_and_belongs_to_many :roles
  
  # Ensure that the table has one entry for each controller/action pair
  def self.synchronize_with_controllers
    ActionController::Routing.controller_paths.each { |controller_path| Dir.foreach(controller_path) { |file_name| require(File.join(controller_path, file_name)) if /_controller.rb$/ =~ file_name && file_name != 'acl_controller.rb' } if File.exist?(controller_path) }
    all_actions = Array.new
    subclasses_of(AclController).each do |klass|
      controllerName = klass.controller_name
      for method in klass.public_instance_methods(false)
        action = "#{controllerName}/#{method.to_s}";
        all_actions << action
      end
    end
    
    # Find all the 'action_path' columns currently in my table
    all_records = self.find(:all)
    known_actions = all_records.collect{ |permission| permission.title }

    # If controllers/actions exist that aren't in the db
    # then add new entries for them
    missing_from_db = all_actions - known_actions
    missing_from_db.each do |action_path|
      self.new( :title => action_path ).save
    end
    # Clear out any entries in the table that do not
    # correspond to an existing controller/action
    bogus_db_actions = known_actions - all_actions
    unless bogus_db_actions.empty? || all_actions.empty? || bogus_db_actions.length > all_actions.length / 2
      #Create a mapping of path->Act instance for quick deletion lookup
      records_by_action_path = { }
      all_records.each do |permission|
        records_by_action_path[ permission.title ] = permission
      end
      bogus_db_actions.each do |action_path|
        records_by_action_path[ action_path ].destroy
      end
    end
  end
  
  def before_destroy
    roles.clear
  end
end
