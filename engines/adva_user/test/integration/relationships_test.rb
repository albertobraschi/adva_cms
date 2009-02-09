require File.expand_path(File.dirname(__FILE__) + '/../test_helper.rb')

module IntegrationTests
  class RelationshipsTest < ActionController::IntegrationTest
    def setup
      super
      @site = use_site! 'site with sections'
      @user = User.find_by_first_name('a user')
      @relationship = @user.relationships.first
    end
    
    test "the user views a empty relationships list" do
      login_as_user
      
      visit_relationships
      display_relationship_index_page
    end
    
    test "the user views non-empty relationships list" do
      login_as_user
      
      with_accepted_relationship do
        visit_relationships
        display_relationship_index_page
      end
    end
    
    # FIXME implement when there are user profiles on adva-cms
    #
    # test "the user sends a relationship request"

    test "the user accepts the relationship request" do
      login_as_user
      
      visit_confirmation_page
      approve_request
      display_relationship_index_page
    end
    
    test "the user declines the relationship request" do
      login_as_user
      
      visit_confirmation_page
      decline_request
      display_relationship_index_page
    end
    
    test "the user goes to the confirmation page of already approved request" do
      login_as_user
      
      with_accepted_relationship do
        visit_confirmation_page
        display_already_approved_message
      end
    end
    
    test "the user removes the relationship" do
      login_as_user
      
      with_accepted_relationship do
        visit_relationships
        click_link_delete
        display_relationship_index_page
      end
    end
    
    def visit_relationships
      get relationships_path
    end
    
    def visit_confirmation_page
      get edit_relationship_path(@relationship)
      assert_template 'relationships/edit'
    end
    
    def display_relationship_index_page
      assert_template 'relationships/index'
    end
    
    def display_already_approved_message
      assert_select "#non-pending_relationship", /You have already approved or declined this relationship request/
    end
    
    def with_accepted_relationship(&block)
      recipient = @relationship.relation
      recipient.relationships.first.request_accept
      yield
    end
    
    def approve_request
      relationships_size = @user.relationships.accepted.size
      
      choose 'confirmation_accepted'
      click_button 'Save'
      
      @user.relationships.reload
      @user.relationships.accepted.size == relationships_size + 1
    end
    
    def decline_request
      relationships_size = @user.relationships.accepted.size
      
      choose 'confirmation_declined'
      click_button 'Save'
      
      @user.relationships.reload
      @user.relationships.accepted.size == relationships_size
    end
    
    def click_link_delete
      relationship_size = @user.relationships.size
      
      click_link "relationship_#{@relationship.id}_delete"
      
      @user.relationships.reload
      assert @user.relationships.size == relationship_size - 1
    end
  end
end