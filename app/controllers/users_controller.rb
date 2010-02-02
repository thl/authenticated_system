class UsersController < AclController
  before_filter :find_person, :except => 'index'
  
  def initialize
    super
    @guest_perms = []
  end
  
  # GET /users
  def index
    redirect_to people_url
  end

  # GET /people/1/user
  # GET /people/1/user.xml
  def show
    @user = @person.user
    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @user.to_xml }
    end
  end

  # GET /people/1/user/edit
  def edit
    @user = @person.user
    @roles = Role.find(:all, :order => 'title')
  end
    
  # GET /people/1/user/new
  # GET /people/1/user/new.xml
  def new
    @user = @person.build_user
    @roles = Role.find(:all, :order => 'title')
  end
  
  def openid_new
  end

  # POST /people/1/user
  # POST /people/1/user.xml
  def create
    if using_open_id?
      authenticate_with_open_id(params['openid_url'], :required => [:nickname, :email]) do |result, identity_url, registration|
        if result.successful?
          @user = User.find_by_identity_url(identity_url)
          if @user.nil?
            @user = User.new do |u|
              u.identity_url = identity_url
              u.login = registration['nickname']
              u.email = registration['email']
            end
            @roles = Role.find(:all, :order => 'title')
            render :action => 'new'
          else
            flash[:notice] = "Identity URL already used by another user!"
            render :action => 'openid_new'
          end
        else
          flash[:notice] = "Could not validate identity URL!"
          render :action => 'openid_new'
        end        
      end
    else
      @user = @person.build_user(params[:user])
      @user.save!
      update_roles(params[:associated_options])
      flash[:notice] = "User succesfully created!"
      redirect_to person_url(@person)
    end
  rescue ActiveRecord::RecordInvalid
    @roles = Role.find(:all, :order => 'title')
    render :action => 'new'
  end

  # PUT /people/1/user
  # PUT /people/1/user.xml
  def update
    @user = @person.user
    update_roles(params[:associated_options])
    respond_to do |format|
      if @user.update_attributes(params[:user])
        flash[:notice] = 'User was successfully updated.'
        format.html { redirect_to people_url }
        format.xml  { head :ok }
      else
        format.html do
          @roles = Role.find(:all, :order => 'title')
          render :action => 'edit' 
        end
        format.xml  { render :xml => @user.errors.to_xml }
      end
    end
  end

  # DELETE /people/1/user
  # DELETE /people/1/user.xml
  def destroy
    @user = @person.user
    @user.destroy

    respond_to do |format|
      format.html { redirect_to people_url }
      format.xml  { head :ok }
    end
  end
  
  protected
  
  def update_roles(user_roles)
    if user_roles.nil?
      new_roles = []
    else
      new_roles = user_roles.collect {|r| r.to_i}
    end
    already_assigned_roles = @user.roles.collect {|r| r.id}
    
    roles_to_create = new_roles - already_assigned_roles
    roles_to_create.each { |role_id| Role.find(role_id).users << @user }

    roles_to_delete = already_assigned_roles - new_roles
    roles_to_delete.each {|role_id| Role.find(role_id).users.delete(@user)}
  end
  
  private
  
  def find_person
    person_id = params[:person_id]
    @person = person_id.blank? ? nil : Person.find(person_id)
  end  
end