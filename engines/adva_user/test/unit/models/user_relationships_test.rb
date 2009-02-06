require File.expand_path(File.dirname(__FILE__) + "/../../test_helper")

class UserRelationshipsTest < ActiveSupport::TestCase
  def setup
    super
    @user         = User.find_by_first_name('a user')
    @second_user  = User.find_by_first_name('a moderator')
    @relationship = @second_user.relationships.first
  end
  
  test "has many relationships" do
    @user.should have_many(:relationships)
  end
  
  test "user.relationships.accepted returns all the accepted relationships the user has" do
    @relationship.request_accept
    
    @user.relationships.accepted.size.should == 1
    @second_user.relationships.accepted.size.should == 1
  end
  
  test "user.relationships.pending returns all the pending relationships the user has" do
    @user.relationships.pending.size.should == 0
    @second_user.relationships.pending.size.should == 1
  end
  
  test "user.relationships.requested returns all the requested relationships the user has" do
    @user.relationships.requested.size.should == 1
    @second_user.relationships.requested.size.should == 0
  end
end