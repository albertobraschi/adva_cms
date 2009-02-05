require File.expand_path(File.dirname(__FILE__) + "/../test_helper")

class RelationshipsControllerTest < ActionController::TestCase
  tests RelationshipsController

  with_common :a_site, :is_user, :a_user_with_relationship

  test "is a BaseController" do
    @controller.should be_kind_of(BaseController)
  end
  
  describe "GET to index" do
    action { get :index }
    
    it_assigns :relationships
  end
  
  describe "GET to show" do
    action { get :show, { :relationship_id => @relationship.id} }
    
    it_assigns :relationship
  end
end