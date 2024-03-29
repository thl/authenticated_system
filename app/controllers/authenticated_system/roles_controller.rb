module AuthenticatedSystem
  class RolesController < AclController  
    def initialize
      super
      @guest_perms = []
    end

    # GET /roles
    # GET /roles.xml
    def index
      @roles = Role.all

      respond_to do |format|
        format.html # index.rhtml
        format.xml  { render :xml => @roles.to_xml }
      end
    end

    # GET /roles/1
    # GET /roles/1.xml
    def show
      @role = Role.find(params[:id])
      @description = @role.description
      @permissions = @role.permissions

      respond_to do |format|
        format.html # show.rhtml
        format.xml  { render :xml => @role.to_xml }
      end
    end

    # GET /roles/new
    def new
      @role = Role.new
      Permission.synchronize_with_controllers
      @permissions = Permission.order('title')
    end

    # GET /roles/1;edit
    def edit
      @role = Role.find(params[:id])
      Permission.synchronize_with_controllers
      @permissions = Permission.order('title')
    end

    # POST /roles
    # POST /roles.xml
    def create
      @role = Role.new(role_params)
      respond_to do |format|
        if @role.save
          update_permissions
          flash[:notice] = ts('new.successful', :what => Role.model_name.human.capitalize)
          format.html { redirect_to authenticated_system_role_url(@role) }
          format.xml  { head :created, :location => authenticated_system_role_url(@role) }
        else
          @permissions = Permission.order('title')
          format.html { render :action => "new" }
          format.xml  { render :xml => @role.errors.to_xml }
        end
      end
    end

    # PUT /roles/1
    # PUT /roles/1.xml
    def update
      @role = Role.find(params[:id])
      respond_to do |format|
        if @role.update(role_params)
          update_permissions
          flash[:notice] = ts('edit.successful', :what => Role.model_name.human.capitalize)
          format.html { redirect_to authenticated_system_role_url(@role) }
          format.xml  { head :ok }
        else
          @permissions = Permission.order('title')
          format.html { render :action => "edit" }
          format.xml  { render :xml => @role.errors.to_xml }
        end
      end
    end

    # DELETE /roles/1
    # DELETE /roles/1.xml
    def destroy
      @role = Role.find(params[:id])
      @role.destroy

      respond_to do |format|
        format.html { redirect_to authenticated_system_roles_url }
        format.xml  { head :ok }
      end
    end

    private

    def update_permissions
      role_permissions = params.require(:associated_options)
      if role_permissions.nil?
        new_permissions = []
      else
        new_permissions = role_permissions.collect {|p| p.to_i}
      end
      already_assigned_permissions = @role.permissions.collect {|p| p.id}

      permissions_to_create = new_permissions - already_assigned_permissions
      permissions_to_create.each { |permission_id| @role.permissions << Permission.find(permission_id) }

      permissions_to_delete = already_assigned_permissions - new_permissions
      permissions_to_delete.each {|permission_id| @role.permissions.delete(Permission.find(permission_id))}
    end
    
    def role_params
      params.require(:role).permit(:title, :description)
    end
  end
end