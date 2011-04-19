class AddSuggestibleFlagToRule < ActiveRecord::Migration
  def self.up
    add_column :rules, :suggestible, :boolean, :default => true, :null => false
  end

  def self.down
    remove_column :rules, :suggestible
  end
end
