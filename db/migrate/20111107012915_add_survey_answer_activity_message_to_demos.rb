class AddSurveyAnswerActivityMessageToDemos < ActiveRecord::Migration
  def self.up
    add_column :demos, :survey_answer_activity_message, :string
    execute "UPDATE demos SET survey_answer_activity_message = ''"
    change_column :demos, :survey_answer_activity_message, :string, :null => false, :default => ""
  end

  def self.down
    remove_column :demos, :survey_answer_activity_message
  end
end
