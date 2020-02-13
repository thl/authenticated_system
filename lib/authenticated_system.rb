require 'authenticated_system/engine'
# ActionView::Base.send :include, AclHelper

module AuthenticatedSystem
  protected
    # Returns true or false if the user is logged in.
    # Preloads @current_user with the user model if they're logged in.
    def logged_in?
      !!current_user
    end

    # Accesses the current user from the session. 
    # Future calls avoid the database because nil is not equal to false.
    def current_user
      @current_user ||= (login_from_session || login_from_basic_auth || login_from_cookie) unless @current_user == false
    end

    # Store the given user id in the session.
    def current_user=(new_user)
      session[:login] = new_user ? new_user.login : nil
      @current_user = new_user || false
    end

    # Check if the user is authorized
    #
    # Override this method in your controllers if you want to restrict access
    # to only a few actions or if you want to check if the user
    # has the correct rights.
    #
    # Example:
    #
    #  # only allow nonbobs
    #  def authorized?
    #    current_user.login != "bob"
    #  end
    def authorized?
      logged_in?
    end

    # Filter method to enforce a login requirement.
    #
    # To require logins for all actions, use this in your controllers:
    #
    #   before_action :login_required
    #
    # To require logins for specific actions, use this in your controllers:
    #
    #   before_action :login_required, :only => [ :edit, :update ]
    #
    # To skip this in a subclassed controller:
    #
    #   skip_before_action :login_required
    #
    def login_required
      authorized? || access_denied
    end

    # Redirect as appropriate when an access request fails.
    #
    # The default action is to redirect to the login screen.
    #
    # Override this method in your controllers if you want to have special
    # behavior in case the user is not authorized
    # to access the requested action.  For example, a popup window might
    # simply close itself.
    def access_denied
      respond_to do |format|
        format.html do
          if logged_in?
            redirect_to root_url(:protocol => 'http')
          else
            store_location
            redirect_to new_authenticated_system_session_url
          end
        end
        format.any do
          request_http_basic_authentication 'Web Password'
        end
      end
    end

    def store_previous_location
      session[:return_to] = request.referrer
    end
    
    def reset_previous_location
      session[:return_to] = nil
    end

    def previous_location
      session[:return_to]
    end

    # Store the URI of the current request in the session.
    #
    # We can return to this location by calling #redirect_back_or_root.
    def store_location
      session[:return_to] = request.fullpath
    end

    # Redirect to the URI stored by the most recent store_location call or
    # to the passed default.
    def redirect_back_or_root
      redirect_to(session[:return_to] || root_url(:protocol => 'http'))
      session[:return_to] = nil
    end

    # Inclusion hook to make #current_user and #logged_in?
    # available as ActionView helper methods.
    def self.included(base)
      base.send :helper_method, :current_user, :logged_in?
    end

    # Called from #current_user.  First attempt to login by the user id stored in the session.
    def login_from_session
      self.current_user = User.find_by(login: session[:login]) if session[:login]
    end

    # Called from #current_user.  Now, attempt to login by basic authentication information.
    def login_from_basic_auth
      authenticate_with_http_basic do |username, password|
        self.current_user = User.authenticate(username, password)
      end
    end

    # Called from #current_user.  Finaly, attempt to login by an expiring token in the cookie.
    def login_from_cookie
      user = cookies[:auth_token] && User.find_by(remember_token: cookies[:auth_token])
      if user && user.remember_token?
        cookies[:auth_token] = { :value => user.remember_token, :expires => user.remember_token_expires_at }
        self.current_user = user
      end
    end
    
    def shibboleth_id
      request.env['HTTP_REMOTE_USER']#.blank? ? session[:netbadgeid] : request.env['HTTP_REMOTE_USER']
    end
    
    def shibboleth_fullname
      "#{request.env['HTTP_GIVENNAME']} #{request.env['HTTP_SN']}"
    end

    def shibboleth_email
      request.env['HTTP_EPPN']
    end
end

ActionController::Base.send :include, AuthenticatedSystem
