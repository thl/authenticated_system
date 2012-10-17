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
    attr_accessible :title, :description
    
    has_and_belongs_to_many :permissions, :order => 'title'
    has_and_belongs_to_many :users

    def before_destroy
      permissions.clear
      users.clear
    end
  end
end
