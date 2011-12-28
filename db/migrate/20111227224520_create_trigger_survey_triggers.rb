class CreateTriggerSurveyTriggers < ActiveRecord::Migration
  def self.up
    create_table :trigger_survey_triggers do |t|
      t.belongs_to :survey
      t.belongs_to :suggested_task
      t.timestamps
    end

    add_index :trigger_survey_triggers, :survey_id
    add_index :trigger_survey_triggers, :suggested_task_id
  end

  def self.down
    drop_table :trigger_survey_triggers
  end
end
