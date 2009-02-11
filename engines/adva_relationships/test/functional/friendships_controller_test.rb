require File.expand_path(File.dirname(__FILE__) + "/../test_helper")

class FriendshipsControllerTest < ActionController::TestCase
  tests FriendshipsController

  with_common :a_site, :is_user, :a_user_with_friendship

  test "is a BaseController" do
    @controller.should be_kind_of(BaseController)
  end
  
  describe "GET to index" do
    action { get :index }
    
    it_assigns :friendships, :friendships_pending
    it_renders_template 'friendships/index'
    it_cache_page_with_references :trach => ['@friendships', '@friendships_pending']
  end
  
  describe "GET to edit" do
    action { get :edit, edit_friendship_params }
    
    it_assigns :friendship => friendship_request
    it_renders_template 'friendships/edit'
    
    it "has an edit form" do
      has_form_putting_to profile_friendship_path(current_user, friendship_request.id) do
        has_tag 'input[id=confirmation_accepted][type=radio]'
        has_tag 'input[id=confirmation_declined][type=radio]'
        has_tag 'input[type=submit]'
      end
    end
  end
  
  describe "POST to create" do
    action { post :create, new_friendship_params }
    
    it_assigns :user => User
    it_assigns_flash_cookie :notice => :not_nil
    it_redirects_to { profile_friendships_path(current_user) }
    it_triggers_event :friendship_requested
    it_sweeps_page_cache :by_reference => :friendship
  end
  
  describe "POST to create, with invalid params" do
    action { post :create, {}}
    
    it_assigns :user => User
    it_assigns_flash_cookie :error => :not_nil
    it_redirects_to { profile_friendships_path(current_user) }
    it_does_not_trigger_any_event
    it_does_not_sweep_page_cache
  end
  
  describe "POST to update, with accepted confirmation" do
    action { put :update, { :id => @friendship.id, :confirmation => Friendship::ACCEPTED }}
    
    it_assigns :user => User
    it_assigns :friendship
    it_assigns_flash_cookie :notice => :not_nil
    it_redirects_to { profile_friendships_path(current_user) }
    it_triggers_event :friendship_accepted
    it_sweeps_page_cache :by_reference => :friendship
  end
  
  describe "POST to update, with accepted confirmation, but with already accepted friendship" do
    with :accepted_friendship do
      action { put :update, { :id => @friendship.id, :confirmation => Friendship::ACCEPTED }}
      
      it_assigns :user => User
      it_assigns :friendship
      it_assigns_flash_cookie :error => :not_nil
      it_renders_template 'friendships/edit'
      it_does_not_trigger_any_event
      it_does_not_sweep_page_cache
    end
  end
  
  describe "POST to update, with accepted confirmation, but with asymmetric friendship (through cancel or delete by other user)" do
    with :cancelled_friendship do
      action { put :update, { :id => @friendship.id, :confirmation => Friendship::ACCEPTED }}
    
      it_assigns :user => User
      it_assigns :friendship
      it_assigns_flash_cookie :error => :not_nil
      it_renders_template 'friendships/edit'
      it_does_not_trigger_any_event
      it_does_not_sweep_page_cache
    end
  end
  
  describe "POST to update, with declined confirmation" do
    action { put :update, { :id => @friendship.id, :confirmation => Friendship::DECLINED }}
    
    it_assigns :user => User
    it_assigns :friendship
    it_assigns_flash_cookie :notice => :not_nil
    it_redirects_to { profile_friendships_path(current_user) }
    it_triggers_event :friendship_declined
    it_sweeps_page_cache :by_reference => :friendship
  end
  
  describe "POST to update, with declined confirmation, but with already accepted friendship" do
    with :accepted_friendship do
      action { put :update, { :id => @friendship.id, :confirmation => Friendship::DECLINED }}
      
      it_assigns :user => User
      it_assigns :friendship
      it_assigns_flash_cookie :error => :not_nil
      it_renders_template 'friendships/edit'
      it_does_not_trigger_any_event
      it_does_not_sweep_page_cache
    end
  end
  
  describe "POST to update, with declined confirmation, but with asymmetric friendship (through cancel or delete by other user)" do
    with :cancelled_friendship do
      action { put :update, { :id => @friendship.id, :confirmation => Friendship::DECLINED }}
    
      it_assigns :user => User
      it_assigns :friendship
      it_assigns_flash_cookie :error => :not_nil
      it_renders_template 'friendships/edit'
      it_does_not_trigger_any_event
      it_does_not_sweep_page_cache
    end
  end
  
  describe "POST to update, without confirmation" do
    action { put :update, { :id => @friendship.id }}
    
    it_assigns :user => User
    it_assigns :friendship
    it_assigns_flash_cookie :error => :not_nil
    it_renders_template 'friendships/edit'
    it_does_not_trigger_any_event
    it_does_not_sweep_page_cache
  end
  
  describe "DELETE to destroy" do
    action { delete :destroy, { :id => @friendship.id }}
    
    it_assigns :friendship
    it_assigns_flash_cookie :notice => :not_nil
    it_redirects_to { profile_friendships_path(current_user) }
    it_triggers_event :friendship_ended
    it_sweeps_page_cache :by_reference => :friendship
  end
  
  def friendship_request
    Friendship.find_by_user_id_and_relation_id @friendship.relation, @friendship.user
  end
  
  def current_user
    @user
  end
  
  def default_params
    { :site_id => @site.id, :user_id => current_user.id }
  end
  
  def new_friendship_params
    relation = User.find_by_first_name('a superuser').id
    default_params.merge(:relation_id => relation)
  end
  
  def edit_friendship_params
    default_params.merge(:id => friendship_request.id)
  end
end