# This controller handles the login/logout function of the site.
module AuthenticatedSystem
  class SessionsController < ApplicationController
    # render show.js.erb
    def show
    end

    # render new.js.erb
    def new
    end

    def create
      if using_open_id?
        open_id_authentication(params[:openid_url])
      else
        password_authentication(params[:login], params[:password])
      end
    end

    def destroy
      self.current_user.forget_me if logged_in?
      cookies.delete :auth_token
      reset_session
      flash[:notice] = "You have been logged out."
      redirect_back_or_default(root_url)
    end
    
    def shibboleth
      # save the REMOTE_USER is the session so we know how this session was authenticated
      # this is used by the sign up action
      session['REMOTE_USER'] = self.shibboleth_id

      if logged_in?
        self.current_user.update_attribute(:shibboleth_id, self.shibboleth_id) if self.current_user.shibboleth_id.blank? && User.find_by_shibboleth_id(self.shibboleth_id).nil?
        redirect_back_or_default(root_url)
        flash[:notice] = "UVa credentials associated successfully."
      elsif self.shibboleth_id.blank?
        failed_login
      else
        user = User.find_by_shibboleth_id(self.shibboleth_id) || User.find_by_email("#{self.shibboleth_id}@virginia.edu") || User.find_by_login(self.shibboleth_id)
        if user.nil?
          # go back to regular http
          #redirect_to signup_netbadge_url
          failed_login
        else
          user.update_attribute(:shibboleth_id, self.shibboleth_id) if user.shibboleth_id.blank? && User.find_by_shibboleth_id(self.shibboleth_id).nil?
          self.current_user = user
          # redirect_to me_url
          successful_login
        end
      end
    end

    protected

    def open_id_authentication(openid_url)
      authenticate_with_open_id(openid_url, :required => [:nickname, :email]) do |result, identity_url, registration|
        if result.successful?
          @user = User.find_by_identity_url(identity_url)
          if @user.nil?
            failed_login result.message
          else
            self.current_user = @user
            successful_login
          end
        else
          failed_login result.message
        end
      end
    end

    def password_authentication(login, password)
      self.current_user = User.authenticate(login, password)
      if logged_in?
        successful_login
      else
        failed_login
      end
    end

    def failed_login(message = "Authentication failed.")
      flash[:notice] = message
      redirect_to new_authenticated_system_session_url
    end

    def successful_login
      if params[:remember_me] == "1"
        self.current_user.remember_me
        cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
      end
      redirect_back_or_default(root_url)
      flash[:notice] = "Logged in successfully"
    end
  end
end