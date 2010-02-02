# == Schema Information
# Schema version: 20090626173648
#
# Table name: roles
#
#  id          :integer(4)      not null, primary key
#  title       :string(20)      not null
#  description :text
#

class Role < ActiveRecord::Base
  has_and_belongs_to_many :permissions, :order => 'title'
  has_and_belongs_to_many :users
  
  def before_destroy
    permissions.clear
    users.clear
  end
end
