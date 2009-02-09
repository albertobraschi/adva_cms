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
    it_renders_template 'relationships/index'
  end
  
  # describe "GET to show" do
  #   action { get :show, { :id => @relationship.id} }
  #   
  #   it_assigns :relationship
  #   it_renders_template 'relationships/show'
  # end
  
  describe "GET to edit" do
    action { get :edit, edit_relationship_params }
    
    it_assigns :relationship => relationship_request
    it_renders_template 'relationships/edit'
    
    it "has an edit form" do
      has_form_putting_to relationship_path(relationship_request.id) do
        has_tag 'input[id=confirmation_accepted][type=radio]'
        has_tag 'input[id=confirmation_declined][type=radio]'
        has_tag 'input[type=submit]'
      end
    end
  end
  
  describe "POST to create" do
    action { post :create, new_relationship_params }
    
    it_assigns :user => User
    it_assigns_flash_cookie :notice => :not_nil
    it_redirects_to { relationships_path }
    it_triggers_event :relationship_requested
  end
  
  describe "POST to create, with invalid params" do
    action { post :create, {}}
    
    it_assigns :user => User
    it_assigns_flash_cookie :error => :not_nil
    it_redirects_to { relationships_path }
    it_does_not_trigger_any_event
  end
  
  describe "POST to update, with accepted confirmation" do
    action { put :update, { :id => @relationship.id, :confirmation => Relationship::ACCEPTED }}
    
    it_assigns :user => User
    it_assigns :relationship
    it_assigns_flash_cookie :notice => :not_nil
    it_redirects_to { relationships_path }
    it_triggers_event :relationship_accepted
  end
  
  describe "POST to update, with accepted confirmation, but with already accepted relationship" do
    with :accepted_relationship do
      action { put :update, { :id => @relationship.id, :confirmation => Relationship::ACCEPTED }}
      
      it_assigns :user => User
      it_assigns :relationship
      it_assigns_flash_cookie :error => :not_nil
      it_renders_template 'relationships/edit'
      it_does_not_trigger_any_event
    end
  end
  
  describe "POST to update, with accepted confirmation, but with asymmetric relationship (through cancel or delete by other user)" do
    with :cancelled_relationship do
      action { put :update, { :id => @relationship.id, :confirmation => Relationship::ACCEPTED }}
    
      it_assigns :user => User
      it_assigns :relationship
      it_assigns_flash_cookie :error => :not_nil
      it_renders_template 'relationships/edit'
      it_does_not_trigger_any_event
    end
  end
  
  describe "POST to update, with declined confirmation" do
    action { put :update, { :id => @relationship.id, :confirmation => Relationship::DECLINED }}
    
    it_assigns :user => User
    it_assigns :relationship
    it_assigns_flash_cookie :notice => :not_nil
    it_redirects_to { relationships_path }
    it_triggers_event :relationship_declined
  end
  
  describe "POST to update, with declined confirmation, but with already accepted relationship" do
    with :accepted_relationship do
      action { put :update, { :id => @relationship.id, :confirmation => Relationship::DECLINED }}
      
      it_assigns :user => User
      it_assigns :relationship
      it_assigns_flash_cookie :error => :not_nil
      it_renders_template 'relationships/edit'
      it_does_not_trigger_any_event
    end
  end
  
  describe "POST to update, with declined confirmation, but with asymmetric relationship (through cancel or delete by other user)" do
    with :cancelled_relationship do
      action { put :update, { :id => @relationship.id, :confirmation => Relationship::DECLINED }}
    
      it_assigns :user => User
      it_assigns :relationship
      it_assigns_flash_cookie :error => :not_nil
      it_renders_template 'relationships/edit'
      it_does_not_trigger_any_event
    end
  end
  
  describe "POST to update, without confirmation" do
    action { put :update, { :id => @relationship.id }}
    
    it_assigns :user => User
    it_assigns :relationship
    it_assigns_flash_cookie :error => :not_nil
    it_renders_template 'relationships/edit'
    it_does_not_trigger_any_event
  end
  
  describe "DELETE to destroy" do
    action { delete :destroy, { :id => @relationship.id }}
    
    it_assigns :relationship
    it_assigns_flash_cookie :notice => :not_nil
    it_redirects_to { relationships_path }
    it_triggers_event :relationship_ended
  end
  
  def relationship_request
    Relationship.find_by_user_id_and_relation_id @relationship.relation, @relationship.user
  end
  
  def default_params
    { :site_id => @site.id }
  end
  
  def new_relationship_params
    default_params.merge(:relation_id => User.find_by_first_name('a superuser').id)
  end
  
  def edit_relationship_params
    default_params.merge(:id => relationship_request.id)
  end
end