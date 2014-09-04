# == Schema Information
#
# Table name: roles
#
#  id          :integer          not null, primary key
#  title       :string(20)       not null
#  description :text
#  created_at  :datetime
#  updated_at  :datetime
#

module AuthenticatedSystem
  class Role < ActiveRecord::Base
    before_destroy do |record|
      record.permissions.clear
      record.users.clear
    end    
    
    has_and_belongs_to_many :permissions, -> { order 'title' }
    has_and_belongs_to_many :users
  end
end
