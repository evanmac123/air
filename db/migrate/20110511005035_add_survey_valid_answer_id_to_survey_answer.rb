class AddSurveyValidAnswerIdToSurveyAnswer < ActiveRecord::Migration
  def self.up
    add_column :survey_answers, :survey_valid_answer_id, :integer
  end

  def self.down
    remove_column :survey_answers, :survey_valid_answer_id
  end
end
