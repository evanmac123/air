class AddCustomVictoryMessagesToDemo < ActiveRecord::Migration
  def self.up
    add_column :demos, :custom_victory_achievement_message, :string
    add_column :demos, :custom_victory_sms, :string, :limit => 150
    add_column :demos, :custom_victory_scoreboard_message, :string
  end

  def self.down
    remove_column :demos, :custom_victory_scoreboard_message
    remove_column :demos, :custom_victory_sms
    remove_column :demos, :custom_victory_achievement_message
  end
end
