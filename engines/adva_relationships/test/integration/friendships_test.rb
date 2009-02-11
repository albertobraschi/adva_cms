require File.expand_path(File.dirname(__FILE__) + '/../test_helper.rb')

module IntegrationTests
  class FriendshipsTest < ActionController::IntegrationTest
    def setup
      super
      @site = use_site! 'site with sections'
      @user = User.find_by_first_name('a user')
      @friendship = @user.friendships.first
    end
    
    test "the user views a empty friendships list" do
      login_as_user
      
      visit_friendships
      display_friendship_index_page
    end
    
    test "the user views non-empty friendships list" do
      login_as_user
      
      with_accepted_friendship do
        visit_friendships
        display_friendship_index_page
      end
    end
    
    # FIXME implement when there are user profiles on adva-cms
    #
    # test "the user sends a friendship request"

    test "the user accepts the friendship request" do
      login_as_user
      
      visit_confirmation_page
      approve_request
      display_friendship_index_page
    end
    
    test "the user declines the friendship request" do
      login_as_user
      
      visit_confirmation_page
      decline_request
      display_friendship_index_page
    end
    
    test "the user goes to the confirmation page of already approved request" do
      login_as_user
      
      with_accepted_friendship do
        visit_confirmation_page
        display_already_approved_message
      end
    end
    
    test "the user removes the friendship" do
      login_as_user
      
      with_accepted_friendship do
        visit_friendships
        click_link_delete
        display_friendship_index_page
      end
    end
    
    def visit_friendships
      get profile_friendships_path(@user)
    end
    
    def visit_confirmation_page
      get edit_profile_friendship_path(@user, @friendship)
      assert_template 'friendships/edit'
    end
    
    def display_friendship_index_page
      assert_template 'friendships/index'
    end
    
    def display_already_approved_message
      assert_select "#non-pending_friendship", /You have already approved or declined this friendship request/
    end
    
    def with_accepted_friendship(&block)
      recipient = @friendship.relation
      recipient.friendships.first.request_accept
      yield
    end
    
    def approve_request
      friendships_size = @user.friendships.accepted.size
      
      choose 'confirmation_accepted'
      click_button 'Save'
      
      @user.friendships.reload
      @user.friendships.accepted.size == friendships_size + 1
    end
    
    def decline_request
      friendships_size = @user.friendships.accepted.size
      
      choose 'confirmation_declined'
      click_button 'Save'
      
      @user.friendships.reload
      @user.friendships.accepted.size == friendships_size
    end
    
    def click_link_delete
      friendship_size = @user.friendships.size
      
      click_link "friendship_#{@friendship.id}_delete"
      
      @user.friendships.reload
      assert @user.friendships.size == friendship_size - 1
    end
  end
end