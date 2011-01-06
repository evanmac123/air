class ActBelongsToRule < ActiveRecord::Migration
  def self.up
    add_column :acts, :rule_id, :integer
    add_index :acts, :rule_id
  end

  def self.down
    remove_column :acts, :rule_id
  end
end
