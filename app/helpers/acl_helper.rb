module AclHelper
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
    return logged_in? && current_user.authorized?(required_perm)
  end
  
  def authorized_only(resource, **options)
    yield if authorized?(resource, options)
  end
  
  def authorized_link_to(name, **options)
    if authorized?(**options)
      return link_to(name, **options)
    else
      return ''
    end
  end
  
  # this method relies on the interface_utils
  def login_status
    if !in_frame?
      if !logged_in?
        return link_to('Login', authenticated_system_login_path, :target => '_top').html_safe
      else
        return link_to("Logout #{current_user.login}", authenticated_system_logout_path, :target => '_top').html_safe
      end
    else
      return ''
    end
  end
  
end