# == Schema Information
# Schema version: 20090626173648
#
# Table name: roles_users
#
#  role_id :integer(4)      not null
#  user_id :integer(4)      not null
#

module AuthenticatedSystem
  class RolesUser < ActiveRecord::Base
    belongs_to :role
    belongs_to :user
  end
end