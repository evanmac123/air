class RenameCleanCommandString < ActiveRecord::Migration
  def self.up
    rename_column :email_commands, :clean_command_string, :clean_body
    add_column :email_commands, :clean_subject, :text
  end

  def self.down
    rename_column :email_commands, :clean_body, :clean_command_string
    remove_columns :email_commands, :clean_subject
  end
end
