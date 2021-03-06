require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper' ))

module IntegrationTests
  class UserRegistrationTest < ActionController::IntegrationTest
    def setup
      super
      @site = use_site! 'site with sections'
    end
  
    test "User clicks through section frontend section index pages" do
      registers_to_site_membership
      verify_the_email_adress
      check_logged_in
    end
  
    def registers_to_site_membership
      visit "/user/new"
      renders_template "user/new"
      
      fill_in "first name", :with => 'John'
      fill_in "last name", :with => 'Doe'
      fill_in "email", :with => 'john-doe@test.com'
      fill_in "password", :with => 'password'
      click_button "Register"
      
      renders_template "user/verification_sent"

      # user record should exist but not be verified
      john_doe.should_not be_nil
      john_doe.verified?.should be_false
      
      # should have sent an email notification
      verification_email.to.should include(john_doe.email)
    end
    
    def verify_the_email_adress
      # extract the verification url from the email
      # http://www.example.com/user/verify?token=1%3Bbd69ea84ed49b61623da2c4d74de2936eb0b0229
      verification_email.body =~ /^(http:.*)$/
      visit $1
      
      john_doe.reload.verified?.should be_true
      request.url.should == "http://#{@site.host}/"
    end
    
    def check_logged_in
      controller.current_user.should == john_doe
    end
    
    
    def john_doe
      @john_doe ||= User.find_by_email('john-doe@test.com')
    end
    
    def verification_email
      @verification_email ||= begin
        ActionMailer::Base.deliveries.should_not be_empty
        ActionMailer::Base.deliveries.first
      end
    end
  end
end