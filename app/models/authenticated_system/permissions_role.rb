# == Schema Information
#
# Table name: permissions_roles
#
#  permission_id :integer          not null
#  role_id       :integer          not null
#

module AuthenticatedSystem
  class PermissionsRole < ActiveRecord::Base
    belongs_to :permission
    belongs_to :role
  end
end
