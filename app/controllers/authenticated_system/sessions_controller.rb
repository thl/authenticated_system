# This controller handles the login/logout function of the site.
module AuthenticatedSystem
  class SessionsController < ApplicationController
    # render show.js.erb
    def show
    end

    # render new.js.erb
    def new
      store_previous_location if previous_location.nil?
    end

    def create
      self.current_user = User.authenticate(params[:login], params[:password])
      if logged_in?
        successful_login
      else
        failed_login
      end
      
    end

    def destroy
      self.current_user.forget_me if logged_in?
      cookies.delete :auth_token
      reset_session
      store_previous_location
      flash[:notice] = "You have been logged out."
      redirect_back_or_root
    end
    
    def shibboleth
      # save the REMOTE_USER is the session so we know how this session was authenticated
      # this is used by the sign up action
      session['REMOTE_USER'] = self.shibboleth_id

      if logged_in?
        self.current_user.update_attribute(:shibboleth_id, self.shibboleth_id) if self.current_user.shibboleth_id.blank? && User.find_by(shibboleth_id: self.shibboleth_id).nil?
        flash[:notice] = "UVa credentials associated successfully."
        redirect_back_or_root
      elsif self.shibboleth_id.blank?
        failed_login
      else
        user = User.find_by(shibboleth_id: self.shibboleth_id) || User.find_by(email: "#{self.shibboleth_id}@virginia.edu")
        if user.nil?
          # go back to regular http
          #redirect_to signup_netbadge_url
          # failed_login
          p = Person.create :fullname => self.shibboleth_fullname
          user = p.build_user :login => self.shibboleth_id, :email => self.shibboleth_email
          user.shibboleth_id = self.shibboleth_id
          user.save
          self.current_user = user
          flash[:notice] = "UVa user created and logged in successfully."
          redirect_back_or_root
        else
          user.update_attribute(:shibboleth_id, self.shibboleth_id) if user.shibboleth_id.blank? && User.find_by(shibboleth_id: self.shibboleth_id).nil?
          self.current_user = user
          # redirect_to me_url
          successful_login
        end
      end
    end
    
    protected
    
    def failed_login(message = "Authentication failed.")
      flash[:notice] = message
      redirect_to new_authenticated_system_session_url
    end

    def successful_login
      if params[:remember_me] == "1"
        self.current_user.remember_me
        cookies.encrypted.signed[:auth_token] = { value: self.current_user.remember_token, expires: self.current_user.remember_token_expires_at }
      else
        self.current_user.forget_me
        cookies.delete(:auth_token)
      end
      redirect_back_or_root
      flash[:notice] = "Logged in successfully"
    end
  end
end
