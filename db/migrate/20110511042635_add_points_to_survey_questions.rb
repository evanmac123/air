class AddPointsToSurveyQuestions < ActiveRecord::Migration
  def self.up
    add_column :survey_questions, :points, :integer
  end

  def self.down
    remove_column :survey_questions, :points
  end
end
