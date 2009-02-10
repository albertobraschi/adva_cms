class Test::Unit::TestCase
  share :a_user_with_friendship do
    before do
      @user = User.find_by_first_name('a user')
      @friendship = @user.friendships.first
    end
  end
  
  share :a_user_with_banship do
    before do
      @user = User.find_by_first_name('a user')
      @banship = @user.banships.first
    end
  end
  
  share :accepted_friendship do
    before do
      @friendship.request_accept
    end
  end
  
  share :cancelled_friendship do
    before do
      user      = @friendship.user
      relation  = @friendship.relation
      Friendship.find_by_user_id_and_relation_id(relation, user).delete
    end
  end
end