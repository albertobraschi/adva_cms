require File.expand_path(File.dirname(__FILE__) + '/../test_helper.rb')

class ProfilesControllerTest < ActionController::TestCase
  tests ProfilesController
  
  with_common :a_site, :a_user
  
  test "is a base controller" do
    @controller.should be_kind_of(BaseController)
  end
  
  describe "GET to index" do
    action { get :index }
    
    it_assigns :users
    it_renders_template 'profiles/index'
    it_caches_the_page :track => ['@users', '@user']
  end
  
  describe "GET to show" do
    action { get :show, default_params }
    
    it_assigns :user
    it_renders_template 'profiles/show'
    #it_caches_the_page :track => ['@users', '@user']
  end
  
  def default_params
    { :id => @user.id }
  end
end