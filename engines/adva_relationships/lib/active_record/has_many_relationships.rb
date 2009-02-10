module ActiveRecord
  module HasManyRelationships
    def self.included(base)
      base.extend ActMacro
    end

    module ActMacro
      def has_many_relationships
        return if has_many_relationships?
        
        has_many :relationships,  :dependent => :delete_all
        has_many :banships,       :dependent => :delete_all
        has_many :friendships,    :dependent => :delete_all
        
        include InstanceMethods
      end

      def has_many_relationships?
        included_modules.include? ActiveRecord::HasManyRelationships::InstanceMethods
      end
    end

    module InstanceMethods
      
    end
  end
end
