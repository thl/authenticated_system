# == Schema Information
#
# Table name: people
#
#  id       :integer          not null, primary key
#  fullname :string           not null
#


# == Schema Information
# Schema version: 20090626173648
#
# Table name: people
#
#  id       :integer(4)      not null, primary key
#  fullname :string(255)     not null
#

module AuthenticatedSystem
  class Person < ActiveRecord::Base
    #has_many :media, :foreign_key => 'photographer_id', :dependent => :nullify
    #has_many :descriptions, :foreign_key => 'creator_id', :dependent => :nullify
    #has_many :administrative_units, :foreign_key => 'creator_id', :dependent => :nullify
    #has_many :captions, :foreign_key => 'creator_id', :dependent => :nullify
    has_one :user, :dependent => :destroy
  end
end
