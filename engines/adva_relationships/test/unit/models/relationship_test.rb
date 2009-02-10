require File.expand_path(File.dirname(__FILE__) + "/../../test_helper")

class RelationshipTest < ActiveSupport::TestCase
  def setup
    super
    @relationship = Relationship.new
    @user         = User.find_by_first_name('a user')
    @second_user  = User.find_by_first_name('a superuser')
  end
  
  # Associations
  
  test "belongs to user" do
    @relationship.should belong_to(:user)
  end

  test "belongs to friend" do
    @relationship.should belong_to(:relation)
  end
  
  # Class methods
  
  # Relationship.request
  
  test "Relationship.request creates a new symmetric relationship between the two users" do
    Relationship.request @user, @second_user
    assert_nothing_raised { Relationship.find_by_user_id_and_relation_id!(@user, @second_user) }
    assert_nothing_raised { Relationship.find_by_user_id_and_relation_id!(@second_user, @user) }
  end
  
  test "Relationship.request creates a new assymmetric relationship between the two users when :assymmetric option is passed" do
    Relationship.request @user, @second_user, :asymmetric
    assert_nothing_raised { Relationship.find_by_user_id_and_relation_id!(@user, @second_user) }
    assert_raise(ActiveRecord::RecordNotFound) { Relationship.find_by_user_id_and_relation_id!(@second_user, @user) }
  end
  
  test "Relationship.request returns false when the kind option is other than :symmetric or :assymmetric" do
    Relationship.request(@user, @second_user, :unknown).should be_false
  end
  
  test "Relationship.request returns false when the user tries to send a request to itself" do
    Relationship.request(@user, @user).should be_false
  end
  
  test "Relationship.request returns false when the user tries to send the request to the other user that is already on the users relations" do
    Relationship.request @user, @second_user
    Relationship.request(@user, @second_user).should be_false
  end
  
  # Relationship.exists?
  
  test "Relationship.exists? returns true when a relationship between two users exists" do
    Relationship.request @user, @second_user
    Relationship.exists?(@user, @second_user).should be_true
  end
  
  test "Relationship.exists? returns false when a relationship between two users does not exist" do
    Relationship.exists?(@user, @second_user).should be_false
  end
  
  # Instance methods
  
  # request_accept
  
  test "#request_accept returns true when the relationship is pending and the request is successfully accepted" do
    relationship = Relationship.request @user, @second_user
    relationship.request_accept.should be_true
  end
  
  test "#request_accept sets the state of the relationships to accepted when ther request is successfully accepted" do
    relationship = Relationship.request @user, @second_user
    relationship.request_accept
    Relationship.instance(@user, @second_user).state.should == Relationship::ACCEPTED
    Relationship.instance(@second_user, @user).state.should == Relationship::ACCEPTED
  end
  
  test "#request_accept returns false if relationship is not pending" do
    relationship = Relationship.request @user, @second_user
    relationship.request_accept
    relationship.reload
    relationship.request_accept.should be_false
  end
  
  # request_decline
  
  test "#request_decline returns true when the relationship is pending and the request is successfully declined" do
    relationship = Relationship.request @user, @second_user
    relationship.request_decline.should be_true
  end
  
  test "#request_decline destroys the relationships when the request is successfully declined" do
    relationship = Relationship.request @user, @second_user
    relationship.request_decline
    assert_raise(ActiveRecord::RecordNotFound) { Relationship.find_by_user_id_and_relation_id!(@user, @second_user) }
    assert_raise(ActiveRecord::RecordNotFound) { Relationship.find_by_user_id_and_relation_id!(@second_user, @user) }
  end
  
  test "#request_decline returns false if the relationship is not pending" do
    relationship = Relationship.request @user, @second_user
    relationship.request_accept
    relationship.reload
    relationship.request_decline.should be_false
  end
  
  # end_relation
  
  test "#remove destroys the relation objects when they are pending" do
    relationship = Relationship.request @user, @second_user
    relationship.remove
    assert_raise(ActiveRecord::RecordNotFound) { Relationship.find_by_user_id_and_relation_id!(@user, @second_user) }
    assert_raise(ActiveRecord::RecordNotFound) { Relationship.find_by_user_id_and_relation_id!(@second_user, @user) }
  end
  
  test "#remove destroys the relation objects when they are accepted" do
    relationship = Relationship.request @user, @second_user
    relationship.request_accept
    relationship.remove
    assert_raise(ActiveRecord::RecordNotFound) { Relationship.find_by_user_id_and_relation_id!(@user, @second_user) }
    assert_raise(ActiveRecord::RecordNotFound) { Relationship.find_by_user_id_and_relation_id!(@second_user, @user) }
  end
  
  test "#remove does not fail with asymmetric relations" do
    relationship = Relationship.request @user, @second_user, :asymmetric
    relationship.remove
    assert_raise(ActiveRecord::RecordNotFound) { Relationship.find_by_user_id_and_relation_id!(@user, @second_user) }
  end
  
  # symmetric?
  
  test "#symmetric? returns true if the relationship is symmetric" do
    relationship = Relationship.request @user, @second_user
    relationship.symmetric?.should be_true
  end
  
  test "#symmetric? returns false if the relationship is not symmetric" do
    relationship = Relationship.request @user, @second_user, :asymmetric
    relationship.symmetric?.should be_false
  end
  
  # asymmetric?
  
  test "#asymmetric? returns true if the relationship is asymmetric" do
    relationship = Relationship.request @user, @second_user, :asymmetric
    relationship.asymmetric?.should be_true
  end
  
  test "#asymmetric? returns false if the relationship is not asymmetric" do
    relationship = Relationship.request @user, @second_user
    relationship.asymmetric?.should be_false
  end
end