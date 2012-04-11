class AddedJoinMethodToDemo < ActiveRecord::Migration
  def self.up
    add_column :demos, :join_type, :text, :null => false, :default => 'pre-populated'
  end

  def self.down
    remove_columns :demos, :join_type
  end
end
