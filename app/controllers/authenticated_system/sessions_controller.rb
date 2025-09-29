# This controller handles the login/logout function of the site.
module AuthenticatedSystem
  class SessionsController < ApplicationController
    allow_unauthenticated_access
    rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_authenticated_system_session_url, alert: "Try again later." }
    
    # render show.js.erb
    def show
    end

    # render new.js.erb
    def new
    end

    def create
      if user = User.authenticate(params[:login], params[:password])
        start_new_session_for user
        successful_login
      else
        redirect_to new_authenticated_system_session_url, alert: "Try another email address or password."
      end
    end

    def destroy
      terminate_session
      flash[:notice] = "You have been logged out."
      redirect_to new_authenticated_system_session_url
    end
    
    def shibboleth
      # save the REMOTE_USER is the session so we know how this session was authenticated
      # this is used by the sign up action
      session['REMOTE_USER'] = self.shibboleth_id

      if authenticated?
        AuthenticatedSystem::Current.user.update_attribute(:shibboleth_id, self.shibboleth_id) if AuthenticatedSystem::Current.user.shibboleth_id.blank? && User.find_by(shibboleth_id: self.shibboleth_id).nil?
        flash[:notice] = "UVa credentials associated successfully."
        redirect_to after_authentication_url
      elsif self.shibboleth_id.blank?
        redirect_to new_authenticated_system_session_url, alert: "Try another email address or password."
      else
        user = User.find_by(shibboleth_id: self.shibboleth_id) || User.find_by(email: "#{self.shibboleth_id}@virginia.edu")
        if user.nil?
          # go back to regular http
          #redirect_to signup_netbadge_url
          # redirect_to new_authenticated_system_session_url, alert: "Try another email address or password."
          p = Person.create :fullname => self.shibboleth_fullname
          user = p.build_user :login => self.shibboleth_id, :email => self.shibboleth_email
          user.shibboleth_id = self.shibboleth_id
          user.save
          flash[:notice] = "UVa user created and logged in successfully."
          start_new_session_for(user)
          redirect_to after_authentication_url
        else
          user.update_attribute(:shibboleth_id, self.shibboleth_id) if user.shibboleth_id.blank? && User.find_by(shibboleth_id: self.shibboleth_id).nil?
          start_new_session_for(user)
          successful_login
        end
      end
    end
    
    protected
    
    def successful_login
      if params[:remember_me] == "1"
        AuthenticatedSystem::Current.user.remember_me
        cookies.encrypted.signed[:auth_token] = { value: AuthenticatedSystem::Current.user.remember_token, expires: AuthenticatedSystem::Current.user.remember_token_expires_at }
      else
        AuthenticatedSystem::Current.user.forget_me
        cookies.delete(:auth_token)
      end
      flash[:notice] = "Logged in successfully"
      redirect_to after_authentication_url
    end
  end
end