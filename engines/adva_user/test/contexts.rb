class Test::Unit::TestCase
  def login(user)
    @user = user
    stub(@controller).current_user.returns(user)
  end

  share :no_user do
    before do 
      User.delete_all
    end
  end

  share :a_user do
    before do 
      @user = User.first
    end
  end
  
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
  
  def valid_user_params
    { :first_name      => 'first name',
      :last_name       => 'last name',
      :email           => 'email@email.org',
      :password        => 'password',
      :homepage        => 'http://homepage.org' }
  end
  
  share :valid_user_params do
    before { @params = { :user => valid_user_params } }
  end
  
  share :invalid_user_params do
    before { @params = { :user => valid_user_params.update(:first_name => '') } }
  end
  
  share :invalid_user_params do
    before { @params = { :user => valid_user_params.update(:email => '') } }
  end
  
  share :invalid_user_params do
    before { @params = { :user => valid_user_params.update(:password => '') } }
  end
end