class AddFollowupWelcomeMessageColumnsToDemos < ActiveRecord::Migration
  def self.up
    add_column :demos, :followup_welcome_message, :string, :limit => 160, :null => false, :default => ''
    add_column :demos, :followup_welcome_message_delay, :integer, :default => 20
  end

  def self.down
    remove_column :demos, :followup_welcome_message_delay
    remove_column :demos, :followup_welcome_message
  end
end
