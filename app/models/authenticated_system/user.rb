# == Schema Information
#
# Table name: users
#
#  id                        :integer          not null, primary key
#  login                     :string           not null
#  email                     :string           not null
#  person_id                 :integer          not null
#  crypted_password          :string(40)
#  salt                      :string(40)
#  remember_token            :string
#  remember_token_expires_at :datetime
#  created_at                :datetime
#  updated_at                :datetime
#  identity_url              :string
#  shibboleth_id             :string
#  access_token              :string
#  password_digest           :string
#
# Indexes
#
#  index_users_on_password_digest  (password_digest)
#  index_users_on_remember_token   (remember_token)
#

require 'digest/sha1'
# require 'authenticated_system/person'

module AuthenticatedSystem
  class User < ActiveRecord::Base
    belongs_to :person
    has_and_belongs_to_many :roles, -> { order 'title' }
    
    # bcrypt
    has_secure_password(validations: false) # you can re-enable validations later
    has_secure_token :remember_token
    
    validates_presence_of     :login, :email
    #validates_presence_of     :password,                   :if => :password_required?
    #validates_presence_of     :password_confirmation,      :if => :password_required?
    #validates_length_of       :password, :within => 4..40, :if => :password_required?
    #validates_confirmation_of :password                    #:if => :password_required?
    validates_length_of       :login,    :within => 3..40
    validates_length_of       :email,    :within => 3..100
    validates_uniqueness_of   :login, :email, :case_sensitive => false
    
    # Legacy helpers (read-only)
    def legacy_encrypted_password   = self[:crypted_password]
    def legacy_salt                 = self[:salt]
    
    # Legacy SHA-1 check (constant-time compare)
    def legacy_authenticated?(plain)
      return false if legacy_encrypted_password.blank? || legacy_salt.blank?
      candidate = Digest::SHA1.hexdigest("--#{legacy_salt}--#{plain}--")
      ActiveSupport::SecurityUtils.secure_compare(legacy_encrypted_password, candidate)
    end
    
    # Unified authenticate
    def authenticate_with_migration(plain)
      # 1) If already on bcrypt:
      if password_digest.present?
        return authenticate(plain) # provided by has_secure_password (returns user or false)
      end

      # 2) Fall back to legacy:
      if legacy_authenticated?(plain)
        # Rehash into bcrypt and clear legacy columns
        self.password = plain
        save!
        # Optionally blank legacy columns to prevent reuse
        update_columns(crypted_password: nil, salt: nil)
        return self
      end
      false
    end
    
    # (Optional) helper used by your code calling User.authenticate(login, password)
    def self.authenticate(login, plain)
      u = find_by(login: login)
      u&.authenticate_with_migration(plain) || nil
    end
    
    # Return true/false if User is authorized for resource.
    def authorized?(resource)
      return permission_strings.include?(resource)
    end
    
    # is the cookie/token still valid?
    def remember_token_valid?
      remember_token.present? && remember_token_expires_at&.future?
    end
    
    # These create and unset the fields required for remembering users between browser closes
    def remember_me
      remember_me_for 2.weeks
    end
    
    def remember_me_for(time = 2.weeks)
      regenerate_remember_token
      # bypass validations to avoid touching unrelated fields
      update_columns(remember_token_expires_at: time.from_now)
    end
    
    def forget_me
      update_columns(remember_token: nil, remember_token_expires_at: nil)
    end
    
    def screen_name
      if person.nil?
        login
      else
        person.fullname
      end
    end

    # Some annoying naming conflict, but HABTM doesn't work, probably conflicting with OpenID gem.
    def roles
      Role.find_by_sql(['SELECT roles.* FROM roles, roles_users WHERE roles.id = roles_users.role_id AND roles_users.user_id = ?', id])
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

      #def password_required?
      #  return false unless self.shibboleth_id.blank? && self.identity_url.blank?
      #  crypted_password.blank? || !password.blank?
      #end
  end
end
