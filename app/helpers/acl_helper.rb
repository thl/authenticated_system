module AclHelper
  def authorized?(resource)
    if resource.class==String
      resource_hash = Rails.application.routes.recognize_path resource
    elsif resource.class==Hash
      resource_hash = resource
    else
      return false
    end
    required_perm = "#{resource_hash[:controller]}/#{resource_hash[:action]}"
    return logged_in? && current_user.authorized?(required_perm)
  end
  
  def authorized_only(resource)
    yield if authorized?(resource)
  end
  
  def authorized_link_to(name, options)
    if authorized?(options)
      return link_to(name, options)
    else
      return ''
    end
  end
  
  # this method relies on the interface_utils
  def login_status
    if !in_frame?
      if !logged_in?
        return "#{link_to 'Login', authenticated_system_login_path}".html_safe
      else
        return "#{current_user.login}. #{link_to 'Logout', authenticated_system_logout_path}".html_safe
      end
    else
      return ''
    end
  end
  
end