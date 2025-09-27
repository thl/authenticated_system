# == Schema Information
#
# Table name: roles_users
#
#  role_id :integer          not null
#  user_id :integer          not null
#
# Indexes
#
#  index_roles_users_on_role_id_and_user_id  (role_id,user_id) UNIQUE
#

module AuthenticatedSystem
  class RolesUser < ActiveRecord::Base
    belongs_to :role
    belongs_to :user
  end
end
