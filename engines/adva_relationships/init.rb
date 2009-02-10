# remove plugin from load_once_paths 
ActiveSupport::Dependencies.load_once_paths -= ActiveSupport::Dependencies.load_once_paths.select{|path| path =~ %r(^#{File.dirname(__FILE__)}) }

ActiveRecord::Base.send :include, ActiveRecord::HasManyRelationships

config.to_prepare do
  User.class_eval do
    has_many_relationships
  end
end

Event.observers << FriendshipMailer