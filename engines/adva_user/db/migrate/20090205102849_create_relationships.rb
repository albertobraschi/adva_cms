class CreateRelationships < ActiveRecord::Migration
  def self.up
    create_table :relationships do |t|
      t.integer :user_id, :relation_id
      t.string  :state
    end
  end

  def self.down
    drop_table :relationships
  end
end
