class CreateSurveyTables < ActiveRecord::Migration
  def self.up
    create_table :surveys do |t|
      t.string :name, :null => false, :default => ''
      t.belongs_to :demo

      t.timestamps
    end

    create_table :survey_questions do |t|
      t.string :text, :null => false, :default => ''
      t.integer :index, :null => false
      t.belongs_to :survey

      t.timestamps
    end

    create_table :survey_prompts do |t|
      t.datetime :send_time, :null => false
      t.string :text, :null => false, :default => ''
      t.belongs_to :survey

      t.timestamps
    end
  end

  def self.down
    drop_table :survey_prompts
    drop_table :survey_questions
    drop_table :surveys
  end
end
