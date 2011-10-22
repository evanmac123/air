class AddAchievementTextAndCompletionSmsTextToGoals < ActiveRecord::Migration
  def self.up
    add_column :goals, :achievement_text, :string
    add_column :goals, :completion_sms_text, :string
   
    execute("UPDATE goals SET achievement_text = '' WHERE achievement_text IS NULL")
    execute("UPDATE goals SET completion_sms_text = '' WHERE completion_sms_text IS NULL")

    change_column :goals, :achievement_text, :string, :null => false, :default => ''
    change_column :goals, :completion_sms_text, :string, :null => false, :default => ''
  end

  def self.down
    remove_column :goals, :completion_sms_text
    remove_column :goals, :achievement_text
  end
end
