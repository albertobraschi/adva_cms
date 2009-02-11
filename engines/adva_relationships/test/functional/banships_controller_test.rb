require File.expand_path(File.dirname(__FILE__) + "/../test_helper")

class BanshipsControllerTest < ActionController::TestCase
  tests BanshipsController

  with_common :a_site, :is_user, :a_user_with_banship

  test "is a BaseController" do
    @controller.should be_kind_of(BaseController)
  end
  
  describe "GET to index" do
    action { get :index }
    
    it_assigns :banships
    it_renders_template 'banships/index'
    it_cache_page_with_references :index, :track => ['@banships']
  end
  
  describe "POST to create" do
    action { post :create, new_banship_params }
    
    it_assigns :user => User
    it_assigns_flash_cookie :notice => :not_nil
    it_redirects_to { profile_banships_path(current_user) }
    it_triggers_event :banship_created
    it_sweeps_page_cache :by_reference => :banship
  end
  
  describe "POST to create, with invalid params" do
    action { post :create, {}}
    
    it_assigns :user => User
    it_assigns_flash_cookie :error => :not_nil
    it_redirects_to { profile_banships_path(current_user) }
    it_does_not_trigger_any_event
    it_does_not_sweep_page_cache
  end
  
  describe "DELETE to destroy" do
    action { delete :destroy, { :id => @banship.id }}
    
    it_assigns :banship
    it_assigns_flash_cookie :notice => :not_nil
    it_redirects_to { profile_banships_path(current_user) }
    it_triggers_event :banship_removed
    it_sweeps_page_cache :by_reference => :banship
  end
  
  def default_params
    { :site_id => @site.id }
  end
  
  def current_user
    @user
  end
  
  def new_banship_params
    default_params.merge(:relation_id => User.find_by_first_name('a superuser').id)
  end
end