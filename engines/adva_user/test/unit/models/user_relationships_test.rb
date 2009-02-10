require File.expand_path(File.dirname(__FILE__) + "/../../test_helper")

class UserRelationshipsTest < ActiveSupport::TestCase
  def setup
    super
    @user         = User.find_by_first_name('a user')
    @second_user  = User.find_by_first_name('a moderator')
    @banned_user  = User.find_by_first_name('the banned user')
    @relationship = @second_user.relationships.first
    @friendship   = @user.friendships.first
    @banship      = @user.banships.first
  end
  
  # Associations
  
  test "has many relationships" do
    @user.should have_many(:relationships)
  end
  
  test "has many friendships" do
    @user.should have_many(:friendships)
  end
  
  test "has many banships" do
    @user.should have_many(:banships)
  end
  
  # Relationships
  
  test "user.relationships.accepted returns all the accepted relationships the user has" do
    @relationship.request_accept
    
    @user.relationships.accepted.size.should == 2
    @second_user.relationships.accepted.size.should == 1
  end
  
  test "user.relationships contains banships" do
    @user.relationships(true).should include(@banship)
  end
  
  test "user.relationships contains friendships" do
    @user.relationships(true).should include(@friendship)
  end
  
  test "user.relationships.pending returns all the pending relationships the user has" do
    @user.relationships.pending.size.should == 0
    @second_user.relationships.pending.size.should == 1
  end
  
  test "user.relationships.requested returns all the requested relationships the user has" do
    @user.relationships.requested.size.should == 1
    @second_user.relationships.requested.size.should == 0
  end
  
  # Friendships
  
  test "user.friendships.accepted returns all the accepted friendships the user has" do
    @friendship.request_accept
    
    @user.friendships.accepted.size.should == 1
    @second_user.friendships.accepted.size.should == 1
  end
  
  test "user.friendships.pending returns all the pending friendships the user has" do
    @user.friendships.pending.size.should == 0
    @second_user.friendships.pending.size.should == 1
  end
  
  test "user.friendships.requested returns all the requested friendships the user has" do
    @user.friendships.requested.size.should == 1
    @second_user.friendships.requested.size.should == 0
  end
  
  # Banships
  
  test "user.banships returns all the banships the user has, banships are not symmetric" do
    @user.banships.size.should == 1
    @banned_user.banships.size.should == 0
  end
end