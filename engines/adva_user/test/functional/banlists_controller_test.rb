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
  end
  
  describe "POST to create" do
    action { post :create, new_banship_params }
    
    it_assigns :user => User
    it_assigns_flash_cookie :notice => :not_nil
    it_redirects_to { banships_path }
    it_triggers_event :banship_created
  end
  
  describe "POST to create, with invalid params" do
    action { post :create, {}}
    
    it_assigns :user => User
    it_assigns_flash_cookie :error => :not_nil
    it_redirects_to { banships_path }
    it_does_not_trigger_any_event
  end
  
  describe "DELETE to destroy" do
    action { delete :destroy, { :id => @banship.id }}
    
    it_assigns :banship
    it_assigns_flash_cookie :notice => :not_nil
    it_redirects_to { banships_path }
    it_triggers_event :banship_removed
  end
  
  def default_params
    { :site_id => @site.id }
  end
  
  def new_banship_params
    default_params.merge(:relation_id => User.find_by_first_name('a superuser').id)
  end
end