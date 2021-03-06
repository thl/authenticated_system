#require 'action_controller'
#require 'application_helper'
#require 'authenticated_system/user'

class AclController < ApplicationController
  # This is a secured controller from which others should derive. They are a limited set
  # of methods which are callable by anyone.  They are defined in the @guest_perms array.
  # By default, #list and #show are unsecured.
  # Example:
  #   class PostsController < AclController
  #      def initialize
  #        super
  #       @guest_perms = [ "posts/summary","posts/show"]
  #      end
  #    end
  #
  before_action :authorize

  def initialize
    super
    # @sections    ||= %w/Users Roles Permissions/
    pretty_name = controller_path
    @guest_perms ||= [ "#{pretty_name}/index", "#{pretty_name}/show"]
    # @guest_perms = []
    # @uri_name = @pretty_name.downcase
    # @edit_uri = "#{@pretty_name.downcase}/edit" 
  end

  protected

  # Authorizes the user for an action.
  def authorize
    required_perm = "#{controller_path}/#{action_name}"
    reset_previous_location
    unless @guest_perms.include? required_perm
      message = String.new
      unless logged_in?
        message = "The #{required_perm} action is not authorized unless you are logged in." 
        #session[:return_to] = session[:prev_uri]
        #ensure you change "user" to your login controller name
        #redirect_to root_url
        #redirect_back_or_root
      else
        unless current_user.authorized? required_perm
          message = "Your user is not authorized to access #{required_perm}."
          #redirect_to root_url
          #redirect_back_or_root
        end
      end
      if !message.blank?
        if request.xhr?
          render :text => "<p style=\"color: green\">#{message}</p>"
        else
          flash[:notice] = message
          access_denied
          # redirect_back fallback_location: root_url
        end
        return false
      end
    end
    #session[:prev_uri] = request.request_uri
    return true
  end
end