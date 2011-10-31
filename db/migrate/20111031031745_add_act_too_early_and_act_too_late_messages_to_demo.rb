class AddActTooEarlyAndActTooLateMessagesToDemo < ActiveRecord::Migration
  def self.up
    add_column :demos, :act_too_early_message, :string
    add_column :demos, :act_too_late_message, :string
    execute "UPDATE demos SET act_too_early_message = '', act_too_late_message = ''"
    change_column :demos, :act_too_early_message, :string, :null => false, :default => ''
    change_column :demos, :act_too_late_message, :string, :null => false, :default => ''
  end

  def self.down
    remove_column :demos, :act_too_late_message
    remove_column :demos, :act_too_early_message
  end
end
