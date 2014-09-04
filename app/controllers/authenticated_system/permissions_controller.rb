module AuthenticatedSystem
  class PermissionsController < AclController
    def initialize
      super
      @guest_perms = []
    end

    # GET /permissions
    # GET /permissions.xml
    def index
      @permissions = Permission.all

      respond_to do |format|
        format.html # index.rhtml
        format.xml  { render :xml => @permissions.to_xml }
      end
    end

    # GET /permissions/1
    # GET /permissions/1.xml
    def show
      @permission = Permission.find(params[:id])

      respond_to do |format|
        format.html # show.rhtml
        format.xml  { render :xml => @permission.to_xml }
      end
    end

    # GET /permissions/new
    def new
      @permission = Permission.new
    end

    # GET /permissions/1;edit
    def edit
      @permission = Permission.find(params[:id])
    end

    # POST /permissions
    # POST /permissions.xml
    def create
      @permission = Permission.new(permission_params)

      respond_to do |format|
        if @permission.save
          flash[:notice] = ts('new.successful', :what => Permission.model_name.human.capitalize)
          format.html { redirect_to authenticated_system_permission_url(@permission) }
          format.xml  { head :created, :location => authenticated_system_permission_url(@permission) }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @permission.errors.to_xml }
        end
      end
    end

    # PUT /permissions/1
    # PUT /permissions/1.xml
    def update
      @permission = Permission.find(params[:id])

      respond_to do |format|
        if @permission.update_attributes(permission_params)
          flash[:notice] = ts('edit.successful', :what => Permission.model_name.human.capitalize)
          format.html { redirect_to authenticated_system_permission_url(@permission) }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @permission.errors.to_xml }
        end
      end
    end

    # DELETE /permissions/1
    # DELETE /permissions/1.xml
    def destroy
      @permission = Permission.find(params[:id])
      @permission.destroy

      respond_to do |format|
        format.html { redirect_to authenticated_system_permissions_url }
        format.xml  { head :ok }
      end
    end
    
    private
    
    def permission_params
      params.require(:permission).permit(:title, :description)
    end
  end
end