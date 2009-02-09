require File.expand_path(File.dirname(__FILE__) + "/../../test_helper")

class RelationshipMailerTest < ActiveSupport::TestCase
  
  def setup
    super
    @user = User.find_by_first_name('a user')
    @relationship = @user.relationships.first
  end

  test "observes events" do
    Event.observers.include?(RelationshipMailer).should be_true
  end
    
  test "implements #handle_relationship_accepted!" do
    RelationshipMailer.should respond_to(:handle_relationship_accepted!)
  end
    
  test "implements #handle_relationship_declined!" do
    RelationshipMailer.should respond_to(:handle_relationship_declined!)
  end
  
  test "implements #handle_relationship_requested!" do
    RelationshipMailer.should respond_to(:handle_relationship_requested!)
  end
    
  test "implements #handle_relationship_ended!" do
    RelationshipMailer.should respond_to(:handle_relationship_ended!)
  end
  
  test "receives #handle_relationship_accepted! when a :relationship_accepted event is triggered" do
    mock(RelationshipMailer).handle_relationship_accepted!.with(anything)
    Event.trigger(:relationship_accepted, @relationship, self)
  end
  
  test "receives #handle_relationship_declined! when a :relationshipe_declined event is triggered" do
    mock(RelationshipMailer).handle_relationship_declined!.with(anything)
    Event.trigger(:relationship_declined, @relationship, self)
  end
  
  test "receives #handle_relationship_requested! when a :relationship_requested event is triggered" do
    mock(RelationshipMailer).handle_relationship_requested!.with(anything)
    Event.trigger(:relationship_requested, @relationship, self)
  end
  
  test "receives #handle_relationship_ended! when a :relationshipe_ended event is triggered" do
    mock(RelationshipMailer).handle_relationship_ended!.with(anything)
    Event.trigger(:relationship_ended, @relationship, self)
  end
end