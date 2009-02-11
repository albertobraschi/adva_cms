require File.expand_path(File.dirname(__FILE__) + '/../../test_helper.rb')

class ProfileTest < ActiveSupport::TestCase
  
  def setup
    @profile = Profile.new
  end
  
  test "belongs to user" do
    @profile.should belong_to(:user)
  end
end
