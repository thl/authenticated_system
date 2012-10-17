# == Schema Information
#
# Table name: roles_users
#
#  role_id :integer          not null
#  user_id :integer          not null
#

module AuthenticatedSystem
  class RolesUser < ActiveRecord::Base
    belongs_to :role
    belongs_to :user
  end
end
