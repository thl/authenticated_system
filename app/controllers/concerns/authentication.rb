module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :require_authentication
    helper_method :authenticated?, :authorized?
  end

  class_methods do
    def allow_unauthenticated_access(**options)
      skip_before_action :require_authentication, **options
    end
  end

  private
    def authenticated?
      resume_session
    end
    
    # from previous implementation
    def authorized?(resource, **options)
      if resource.class==String
        app = Rails.application
        relative_root = app.config.relative_url_root
        resource = resource[relative_root.size..resource.size] if !relative_root.blank?
        resource_hash = app.routes.recognize_path resource
      elsif resource.class==Hash
        resource_hash = resource
      else
        return false
      end
      resource_hash.merge! options
      required_perm = "#{resource_hash[:controller]}/#{resource_hash[:action]}"
      return authenticated? && AuthenticatedSystem::Current.user.authorized?(required_perm)
    end

    def require_authentication
      #resume_session || request_authentication
      
      # making code compatible with previous implementation
      if resume_session
        required_perm = "#{controller_path}/#{action_name}"
        message = String.new
        unless AuthenticatedSystem::Current.user.authorized? required_perm
          message = "Your user is not authorized to access #{required_perm}."
          if request.xhr?
            render :text => "<p style=\"color: green\">#{message}</p>"
          else
            flash[:notice] = message
          end
          redirect_back fallback_location: root_path
        end
      else
        request_authentication
      end
    end

    def resume_session
      #Current.session ||= find_session_by_cookie
      AuthenticatedSystem::Current.user ||= login_from_session || login_from_remember_token
    end

    def login_from_session
      #Session.find_by(id: cookies.signed[:session_id]) if cookies.signed[:session_id]
      AuthenticatedSystem::User.find_by(login: session[:login]) if session[:login]
    end
    
    # Attempt to login by an expiring token in the cookie.
    def login_from_remember_token
      if cookies.encrypted.signed[:auth_token].present?
        user = User.find_by(remember_token: cookies.encrypted.signed[:auth_token])
        if user&.remember_token_valid?
          AuthenticatedSystem::Current.user = user
        else
          user&.forget_me
          cookies.delete(:auth_token)
        end
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

    def request_authentication
      session[:return_to_after_authenticating] = request.url
      
      # added for messaging
      message = "The page you requested requires that you are logged in." 
      if request.xhr?
        render :text => "<p style=\"color: green\">#{message}</p>"
      else
        flash[:notice] = message
      end
      redirect_to new_authenticated_system_session_path
    end

    def after_authentication_url
      session.delete(:return_to_after_authenticating) || root_url
    end

    def start_new_session_for(user)
#      user.sessions.create!(user_agent: request.user_agent, ip_address: request.remote_ip).tap do |session|
#        Current.session = session
#        cookies.signed.permanent[:session_id] = { value: session.id, httponly: true, same_site: :lax }
#      end
      AuthenticatedSystem::Current.user = user
      session[:login] = user.login
    end

    def terminate_session
      #Current.session.destroy
      #cookies.delete(:session_id)      
      AuthenticatedSystem::Current.user.forget_me if authenticated?
      AuthenticatedSystem::Current.user = nil      
      cookies.delete :auth_token
      reset_session
    end
end