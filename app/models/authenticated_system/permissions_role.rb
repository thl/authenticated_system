# == Schema Information
#
# Table name: permissions_roles
#
#  permission_id :integer          not null
#  role_id       :integer          not null
#
# Indexes
#
#  index_permissions_roles_on_permission_id_and_role_id  (permission_id,role_id) UNIQUE
#

module AuthenticatedSystem
  class PermissionsRole < ActiveRecord::Base
    belongs_to :permission
    belongs_to :role
  end
end
