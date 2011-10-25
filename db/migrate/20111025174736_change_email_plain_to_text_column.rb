class ChangeEmailPlainToTextColumn < ActiveRecord::Migration
  def self.up
    change_column :email_commands, :email_plain, :text
  end

  def self.down
    change_column :email_commands, :email_plain, :string
  end
end
