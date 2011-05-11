class CreateSurveyAnswers < ActiveRecord::Migration
  def self.up
    create_table :survey_answers do |t|
      t.belongs_to :user
      t.belongs_to :survey_question

      t.timestamps
    end
  end

  def self.down
    drop_table :survey_answers
  end
end
