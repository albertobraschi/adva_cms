class AddTypeToRelationships < ActiveRecord::Migration
  def self.up
    add_column :relationships, :type, :string
  end

  def self.down
    remove_column :relationships, :type
  end
end
