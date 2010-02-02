module AclHelper
  def authorized?(resource)
    if resource.class==String
      required_perm = resource
    elsif resource.class==Hash
      required_perm = "#{resource[:controller]}/#{resource[:action]}"
    else
      return false
    end
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
end