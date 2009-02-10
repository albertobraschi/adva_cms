class FriendshipsController < BaseController
  
  before_filter :set_friendship,  :only => :destroy
  before_filter :set_user,        :only => :create
  before_filter :get_request,     :only => [:edit, :update]
  
  def index
    @friendships = current_user.friendships.accepted
  end
  
  def create
    if Friendship.request(current_user, @user)
      trigger_events Friendship.instance(current_user, @user), :requested
      flash[:notice] = "Friend request was successfully sent to #{@user.name}."
    else
      flash[:error] = "Sending a friend request to #{@user.name} failed."
    end
    redirect_to (params[:return_to] || friendships_path)
  end
  
  def edit
  end
  
  def update
    if params[:confirmation]
      params[:confirmation] == Friendship::ACCEPTED ? request_accept : request_decline
    else
      flash[:error] = "You have to either confirm or decline the friend request!"
      render :action => 'edit'
    end
  end
  
  def request_accept
    if @friendship.request_accept
      trigger_event @friendship, :accepted
      flash[:notice] = "The friend request was successfully accepted!"
      redirect_to (params[:return_to] || friendships_path)
    else
      flash[:error] = "The friend request could not be accepted!"
      render :action => 'edit'
    end
  end
  
  def request_decline
    if @friendship.request_decline
      trigger_event @friendship, :declined
      flash[:notice] = "The friend request was successfully declined!"
      redirect_to (params[:return_to] || friendships_path)
    else
      flash[:error] = "The friend request could not be declined!"
      render :action => 'edit'
    end
  end
  
  def destroy
    if @friendship.remove
      trigger_event @friendship, :ended, :user => current_user
      flash[:notice] = "Friendship was successfully deleted!"
    else
      flash[:error] = "The friend request could not be deleted!"
    end
    redirect_to (params[:return_to] || friendships_path)
  end
  
  protected
    def set_friendship
      @friendship = current_user.friendships.find params[:id]
    rescue ActiveRecord::RecordNotFound
      flash[:error] = "The friendship you requested could not be found."
      write_flash_to_cookie # TODO make around filter or something
      redirect_to (params[:return_to] || friendships_path)
    end
    
    def get_request
      @friendship = Friendship.find params[:id]
    rescue ActiveRecord::RecordNotFound
      flash[:error] = "The friendship you requested could not be found."
      write_flash_to_cookie # TODO make around filter or something
      redirect_to (params[:return_to] || friendships_path)
    end
    
    def set_user
      @user = User.find(params[:relation_id])
    rescue ActiveRecord::RecordNotFound
      flash[:error] = "The user you wanted to send the friend request does not exist anymore!"
      write_flash_to_cookie # TODO make around filter or something
      redirect_to (params[:return_to] || friendships_path)
    end
end