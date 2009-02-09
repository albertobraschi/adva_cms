class RelationshipMailer < ActionMailer::Base
  include Login::MailConfig
  
  class << self
    def handle_relationship_accepted!(event)
      deliver_relationship_accepted_email event.object
    end
    
    def handle_relationship_declined!(event)
      deliver_relationship_declined_email event.object
    end
    
    def handle_relationship_requested!(event)
      deliver_relationship_requested_email event.object
    end
    
    def handle_relationship_ended!(event)
      deliver_relationship_ended_email event.object, event.options[:user]
    end
  end

  def relationship_accepted_email(relationship)
    recipient = relationship.user
    
    recipients recipient.email
    from system_email(relationship_path(relationship))
    subject 'Your relationship request was accepted!'
    body :user_requested => relationship.user, :user_accepted => relationship.relation
  end

  def relationship_declined_email(relationship)
    recipient = relationship.user
    
    recipients recipient.email
    from system_email(relationship_path(relationship))
    subject 'Your relationship request was declined!'
    body :user_requested => relationship.user, :user_declined => relationship.relation
  end

  def relationship_requested_email(relationship)
    recipient = relationship.relation
    
    recipients recipient.email
    from system_email(relationship_path(relationship))
    subject 'You have a request for a relationship!'
    body :user_requested => relationship.user, :recipient => relationship.relation,
         :confirmation_url => edit_relationship_path(relationship)
  end

  def relationship_ended_email(relationship, user)
    recipient = relationship.user == user ? relationship.relation : relationship.user
    
    recipients recipient
    from system_email(relationship_path(relationship))
    subject 'One of your relationships has brokeup!'
    body :user_ended => user, :recipient => recipient
  end
end
