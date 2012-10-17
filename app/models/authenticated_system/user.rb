# == Schema Information
# Schema version: 20090626173648
#
# Table name: users
#
#  id                        :integer(4)      not null, primary key
#  person_id                 :integer(4)
#  login                     :string(80)      not null
#  crypted_password          :string(40)
#  identity_url              :string(255)
#  email                     :string(255)
#  salt                      :string(40)
#  created_at                :datetime
#  updated_at                :datetime
#  remember_token            :string(255)
#  remember_token_expires_at :datetime
#

require 'digest/sha1'
# require 'authenticated_system/person'

module AuthenticatedSystem
  class User < ActiveRecord::Base
    belongs_to :person
    has_and_belongs_to_many :roles, :order => 'title'

    # Virtual attribute for the unencrypted password
    attr_accessor :password
    attr_accessible :identity_url, :login, :email
    

    validates_presence_of     :login, :email
    validates_presence_of     :password,                   :if => :password_required?
    validates_presence_of     :password_confirmation,      :if => :password_required?
    validates_length_of       :password, :within => 4..40, :if => :password_required?
    validates_confirmation_of :password,                   :if => :password_required?
    validates_length_of       :login,    :within => 3..40
    validates_length_of       :email,    :within => 3..100
    validates_uniqueness_of   :login, :email, :case_sensitive => false
    before_save :encrypt_password

    # prevents a user from submitting a crafted form that bypasses activation
    # anything else you want your user to change should be added here.
    attr_accessible :login, :email, :password, :password_confirmation, :identity_url

    def screen_name
      if person.nil?
        login
      else
        person.fullname
      end
    end

    # has_and_belongs_to_many :roles, :order => 'title'
    # Some annoying naming conflict, but HABTM doesn't work, probably conflicting with OpenID gem.   
    def roles
      Role.find_by_sql(['SELECT roles.* FROM roles, roles_users WHERE roles.id = roles_users.role_id AND roles_users.user_id = ?', id])
    end

    # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
    def self.authenticate(login, password)
      u = find_by_login(login) # need to get the salt
      u && u.authenticated?(password) ? u : nil
    end

    # Encrypts some data with the salt.
    def self.encrypt(password, salt)
      Digest::SHA1.hexdigest("--#{salt}--#{password}--")
      #Digest::SHA1.hexdigest(password)
    end

    # Encrypts the password with the user salt
    def encrypt(password)
      self.class.encrypt(password, salt)
    end

    def authenticated?(password)
      crypted_password == encrypt(password)
    end

    def remember_token?
      remember_token_expires_at && Time.now.utc < remember_token_expires_at 
    end

    # These create and unset the fields required for remembering users between browser closes
    def remember_me
      remember_me_for 2.weeks
    end

    def remember_me_for(time)
      remember_me_until time.from_now.utc
    end

    def remember_me_until(time)
      self.remember_token_expires_at = time
      self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
      save(:validate => false)
    end

    def forget_me
      self.remember_token_expires_at = nil
      self.remember_token            = nil
      save(:validate => false)
    end

    # Return true/false if User is authorized for resource.
    def authorized?(resource)
      return permission_strings.include?(resource)
    end

    # Load permission strings 
    def permission_strings
      #a = []
      #roles.each { |r| r.permissions.each { |p| a<< p.title } }
      #a
      Permission.find_by_sql(['SELECT permissions.* FROM permissions, permissions_roles, roles_users WHERE permissions.id = permissions_roles.permission_id AND permissions_roles.role_id = roles_users.role_id AND roles_users.user_id = ?', id]).collect { |p| p.title }
    end

    protected
      # before filter 
      def encrypt_password
        return if password.blank?
        self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
        self.crypted_password = encrypt(password)
      end

      def password_required?
        return false unless self.shibboleth_id.blank? && self.identity_url.blank?
        crypted_password.blank? || !password.blank?
      end
  end
end