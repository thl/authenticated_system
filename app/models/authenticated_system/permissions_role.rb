# == Schema Information
# Schema version: 20090626173648
#
# Table name: permissions_roles
#
#  permission_id :integer(4)      not null
#  role_id       :integer(4)      not null
#

module AuthenticatedSystem
  class PermissionsRole < ActiveRecord::Base
    belongs_to :permission
    belongs_to :role
  end
end