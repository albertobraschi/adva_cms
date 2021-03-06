require File.expand_path(File.dirname(__FILE__) + '/../test_helper' )

module IntegrationTests
  class SectionCommentTest < ActionController::IntegrationTest
    def setup
      super
      @site = use_site! 'site with sections'
      @site.update_attributes! :permissions => { 'create comment' => 'anonymous' }
      @published_article = Article.find_by_title 'a section article'
    end
    
    # FIXME test edit/delete comment
    # http://artweb-design.lighthouseapp.com/projects/13992/tickets/215
    test "An anonymous user posts a comment to a section article" do
      post_a_section_comment_as_anonymous
      view_submitted_comment
      go_back_to_article
    end
    
    test "A registered user posts a comment to a section article" do
      login_as_user
      post_a_section_comment_as_user
      view_submitted_comment
      go_back_to_article
    end
    
    def post_a_section_comment_as_anonymous
      visit '/articles/a-section-article'
      fill_in "user_name", :with => "John Doe"
      fill_in "user_email", :with => "john@example.com"
      fill_in "comment_body", :with => "What a nice article!"
      click_button "Submit comment"
    end
    
    def post_a_section_comment_as_user
      visit '/articles/a-section-article'
      fill_in "comment_body", :with => "What a nice article!"
      click_button "Submit comment"
    end
    
    def view_submitted_comment
      request.url.should =~ %r(#{@site.host}/comments/\d+)
      has_tag ".comment", /What a nice article!/
    end
    
    def go_back_to_article
      click_link 'a section article'
      request.url.should == "http://#{@site.host}/articles/a-section-article"
    end
  end
end