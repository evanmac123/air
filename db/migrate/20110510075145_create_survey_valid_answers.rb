class CreateSurveyValidAnswers < ActiveRecord::Migration
  def self.up
    create_table :survey_valid_answers do |t|
      t.string :value, :null => false, :default => ''

      t.belongs_to :survey_question

      t.timestamps
    end
  end

  def self.down
    drop_table :survey_valid_answers
  end
end
