class EmailCommandCleanCommandStringToText < ActiveRecord::Migration
  def self.up
    change_column :email_commands, :clean_command_string, :text
  end

  def self.down
    change_column :email_commands, :clean_command_string, :string
  end
end
