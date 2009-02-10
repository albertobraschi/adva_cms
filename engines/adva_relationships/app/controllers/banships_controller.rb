class BanshipsController < BaseController
    
  before_filter :set_banship,  :only => :destroy
  before_filter :set_user,     :only => :create
  
  caches_page_with_references :index, :track => ['@banships']
  cache_sweeper :relationship_sweeper, :only => [:create, :destroy]
    
  def index
    @banships = current_user.banships
  end
  
  def create
    if Banship.request(current_user, @user)
      trigger_events Banship.instance(current_user, @user), :created
      flash[:notice] = "#{@user.name} was successfully added to your banlist."
    else
      flash[:error] = "Adding #{@user.name} to the banlist failed."
    end
    redirect_to (params[:return_to] || banships_path)
  end
  
  def destroy
    if @banship.remove
      trigger_event @banship, :removed
      flash[:notice] = "The ban was successfully removed!"
    else
      flash[:error] = "The ban could not be removed!"
    end
    redirect_to (params[:return_to] || banships_path)
  end
  
  protected
    def set_banship
      @banship = current_user.banships.find params[:id]
    rescue ActiveRecord::RecordNotFound
      flash[:error] = "The ban you requested could not be found."
      write_flash_to_cookie # TODO make around filter or something
      redirect_to (params[:return_to] || banships_path)
    end
    
    def get_request
      @banship = Banship.find params[:id]
    rescue ActiveRecord::RecordNotFound
      flash[:error] = "The ban you requested could not be found."
      write_flash_to_cookie # TODO make around filter or something
      redirect_to (params[:return_to] || banships_path)
    end
    
    def set_user
      @user = User.find(params[:relation_id])
    rescue ActiveRecord::RecordNotFound
      flash[:error] = "The user you wanted to ban does not exist anymore!"
      write_flash_to_cookie # TODO make around filter or something
      redirect_to (params[:return_to] || banships_path)
    end
end