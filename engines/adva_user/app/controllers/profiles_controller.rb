class ProfilesController < BaseController
  
  before_filter :set_user, :only => :show
  
  caches_page_with_references :index, :track => ['@user', '@users']

  def index
    @users  = @site.users.verified
  end
  
  def show
  end
  
  protected
    def set_user
      @user = User.find params[:id]
    rescue ActiveRecord::RecordNotFound
      flash[:error] = "The user you requested could not be found."
      write_flash_to_cookie # TODO make around filter or something
      redirect_to (params[:return_to] || profiles_path)
    end
end