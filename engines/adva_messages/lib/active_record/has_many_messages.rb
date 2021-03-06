module ActiveRecord
  module HasManyMessages
    def self.included(base)
      base.extend ActMacro
    end

    module ActMacro
      def has_many_messages(options = {})
        return if has_many_messages?
        
        has_many :messages_received,
                 :class_name  => "Message",
                 :foreign_key => "recipient_id",
                 :conditions  => ["deleted_at_recipient IS NULL"]
        
        has_many :messages_sent,
                 :class_name  => "Message",
                 :foreign_key => "sender_id",
                 :conditions  => ["deleted_at_sender IS NULL"]
        
        has_many :conversations,
                 :through     => :messages_received,
                 :uniq        => true
        # 
        # has_many :conversations_sent,
        #          :through     => :messages_sent,
        #          :uniq        => true
        
        include InstanceMethods
      end

      def has_many_messages?
        included_modules.include? ActiveRecord::HasManyMessages::InstanceMethods
      end
    end
    
    module InstanceMethods  
      def messages
        (messages_received + messages_sent).uniq
      end
      
      def my_conversations
        messages.collect {|m| m.conversation }.uniq
      end
    end
    
  end
end