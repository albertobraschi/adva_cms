require File.expand_path(File.dirname(__FILE__) + '/../test_helper.rb')

module IntegrationTests
  class BanshipsTest < ActionController::IntegrationTest
    def setup
      super
      @site     = use_site! 'site with sections'
      @user     = User.find_by_first_name('a user')
      @banship  = @user.banships.first
    end
  
    test "the user views the banships list" do
      login_as_user
      visit_banships
      display_banship_index_page
    end
    
    # FIXME implement when there are user profiles on adva-cms
    #
    # test "the user adds another user to banlist"
    
    test "the user removes the banship" do
      login_as_user
      
      visit_banships
      click_link_delete
      display_banship_index_page
    end
    
    def visit_banships
      get profile_banships_path(@user)
    end
    
    def display_banship_index_page
      assert_template 'banships/index'
    end
    
    def click_link_delete
      banship_size = @user.banships.size
      
      click_link "banship_#{@banship.id}_delete"
      
      @user.banships.reload
      assert @user.banships.size == banship_size - 1
    end
  end
end