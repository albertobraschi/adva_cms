require File.expand_path(File.dirname(__FILE__) + "/../../test_helper")

class FriendshipMailerTest < ActiveSupport::TestCase
  
  def setup
    super
    @user = User.find_by_first_name('a user')
    @friendship = @user.friendships.first
  end

  test "observes events" do
    Event.observers.include?(FriendshipMailer).should be_true
  end
    
  test "implements #handle_friendship_accepted!" do
    FriendshipMailer.should respond_to(:handle_friendship_accepted!)
  end
    
  test "implements #handle_friendship_declined!" do
    FriendshipMailer.should respond_to(:handle_friendship_declined!)
  end
  
  test "implements #handle_friendship_requested!" do
    FriendshipMailer.should respond_to(:handle_friendship_requested!)
  end
    
  test "implements #handle_friendship_ended!" do
    FriendshipMailer.should respond_to(:handle_friendship_ended!)
  end
  
  test "receives #handle_friendship_accepted! when a :friendship_accepted event is triggered" do
    mock(FriendshipMailer).handle_friendship_accepted!.with(anything)
    Event.trigger(:friendship_accepted, @friendship, self)
  end
  
  test "receives #handle_friendship_declined! when a :friendshipe_declined event is triggered" do
    mock(FriendshipMailer).handle_friendship_declined!.with(anything)
    Event.trigger(:friendship_declined, @friendship, self)
  end
  
  test "receives #handle_friendship_requested! when a :friendship_requested event is triggered" do
    mock(FriendshipMailer).handle_friendship_requested!.with(anything)
    Event.trigger(:friendship_requested, @friendship, self)
  end
  
  test "receives #handle_friendship_ended! when a :friendship_ended event is triggered" do
    mock(FriendshipMailer).handle_friendship_ended!.with(anything)
    Event.trigger(:friendship_ended, @friendship, self)
  end
end