class FriendshipMailer < ActionMailer::Base
  include Login::MailConfig
  
  class << self
    def handle_friendship_accepted!(event)
      deliver_friendship_accepted_email event.object
    end
    
    def handle_friendship_declined!(event)
      deliver_friendship_declined_email event.object
    end
    
    def handle_friendship_requested!(event)
      deliver_friendship_requested_email event.object
    end
    
    def handle_friendship_ended!(event)
      deliver_friendship_ended_email event.object, event.options[:user]
    end
  end

  def friendship_accepted_email(friendship)
    recipient = friendship.user
    
    recipients recipient.email
    from system_email(friendship_path(friendship))
    subject 'Your friendship request was accepted!'
    body :user_requested => friendship.user, :user_accepted => friendship.relation
  end

  def friendship_declined_email(friendship)
    recipient = friendship.user
    
    recipients recipient.email
    from system_email(friendship_path(friendship))
    subject 'Your friendship request was declined!'
    body :user_requested => friendship.user, :user_declined => friendship.relation
  end

  def friendship_requested_email(friendship)
    recipient = friendship.relation
    
    recipients recipient.email
    from system_email(friendship_path(friendship))
    subject 'You have a request for a friendship!'
    body :user_requested => friendship.user, :recipient => friendship.relation,
         :confirmation_url => edit_friendship_path(friendship)
  end

  def friendship_ended_email(friendship, user)
    recipient = friendship.user == user ? friendship.relation : friendship.user
    
    recipients recipient
    from system_email(friendship_path(friendship))
    subject 'One of your friendships has brokeup!'
    body :user_ended => user, :recipient => recipient
  end
end
