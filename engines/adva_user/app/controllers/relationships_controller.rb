class RelationshipsController < BaseController
  
  before_filter :set_relationship, :only => [:show, :destroy]
  before_filter :set_user, :only => :create
  before_filter :get_request, :only => [:edit, :update]
  
  authenticates_anonymous_user
  
  def index
    @relationships = current_user.relationships.accepted
  end

  # FIXME does this actually have any function to relationships?
  # def show
  # end
  
  def create
    if Relationship.request(current_user, @user)
      flash[:notice] = "Request was successfully sent to #{@user.name}."
    else
      flash[:error] = "Sending a request to #{@user.name} failed."
    end
    redirect_to (params[:return_to] || relationships_path)
  end
  
  def edit
  end
  
  def update
    if params[:confirmation]
      params[:confirmation] == Relationship::ACCEPTED ? request_accept : request_decline
    else
      flash[:error] = "You have to either confirm or decline the request!"
      render :action => 'edit'
    end
  end
  
  def request_accept
    if @relationship.request_accept
      flash[:notice] = "Request was successfully accepted!"
      redirect_to (params[:return_to] || relationships_path)
    else
      flash[:error] = "Accepting of the request failed!"
      render :action => 'edit'
    end
  end
  
  def request_decline
    if @relationship.request_decline
      flash[:notice] = "Request was successfully declined!"
      redirect_to (params[:return_to] || relationships_path)
    else
      flash[:error] = "Declining of the request failed!"
      render :action => 'edit'
    end
  end
  
  def destroy
    if @relationship.remove
      flash[:notice] = "Relationship was successfully deleted!"
    else
      flash[:error] = "Deleting of the relationship failed!"
    end
    redirect_to (params[:return_to] || relationships_path)
  end
  
  protected
    def set_relationship
      @relationship = current_user.relationships.find params[:id]
    rescue ActiveRecord::RecordNotFound
      flash[:error] = "Relation you requested could not be found."
      write_flash_to_cookie # TODO make around filter or something
      redirect_to (params[:return_to] || relationships_path)
    end
    
    def get_request
      @relationship = Relationship.find params[:id]
    rescue ActiveRecord::RecordNotFound
      flash[:error] = "Relation you requested could not be found."
      write_flash_to_cookie # TODO make around filter or something
      redirect_to (params[:return_to] || relationships_path)
    end
    
    def set_user
      @user = User.find(params[:relation_id])
    rescue ActiveRecord::RecordNotFound
      flash[:error] = "The user you wanted to send a request does not exist!"
      write_flash_to_cookie # TODO make around filter or something
      redirect_to (params[:return_to] || relationships_path)
    end
end