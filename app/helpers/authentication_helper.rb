module AuthenticationHelper
  def authorized?(resource, **options)
    AuthenticatedSystem::Current.user&.authorized?(resource, **options)
  end
  # this method relies on the interface_utils
  def login_status
    if !in_frame?
      if authenticated?
        return link_to("Logout #{AuthenticatedSystem::Current.user.login}", authenticated_system_logout_path, :target => '_top').html_safe
      else
        return link_to('Login', authenticated_system_login_path, :target => '_top').html_safe
      end
    else
      return ''
    end
  end
  
end