class AddIndexesToSurveyStuff < ActiveRecord::Migration
  def self.up
    add_index :surveys, :demo_id
    add_index :surveys, :open_at
    add_index :surveys, :close_at

    add_index :survey_answers, :user_id
    add_index :survey_answers, :survey_question_id
    add_index :survey_answers, :survey_valid_answer_id

    add_index :survey_prompts, :survey_id

    add_index :survey_questions, :index
    add_index :survey_questions, :survey_id

    add_index :survey_valid_answers, :value
    add_index :survey_valid_answers, :survey_question_id
  end

  def self.down
    remove_index :survey_valid_answers, :column => :survey_question_id
    remove_index :survey_valid_answers, :column => :value

    remove_index :survey_questions, :column => :survey_id
    remove_index :survey_questions, :column => :index

    remove_index :survey_prompts, :column => :survey_id

    remove_index :survey_answers, :column => :survey_valid_answer_id
    remove_index :survey_answers, :column => :survey_question_id
    remove_index :survey_answers, :column => :user_id

    remove_index :surveys, :column => :close_at
    remove_index :surveys, :column => :open_at
    remove_index :surveys, :column => :demo_id
  end
end
