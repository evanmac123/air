class AddHelpMessageToDemos < ActiveRecord::Migration
  def self.up
    add_column :demos, :help_message, :string
    execute "UPDATE demos SET help_message = '' WHERE help_message IS NULL"
    change_column :demos, :help_message, :string, :default => '', :null => false
  end

  def self.down
    remove_column :demos, :help_message
  end
end
