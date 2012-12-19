class SurveyDemographicRuleAllNeedTileInsteadOfTask < ActiveRecord::Migration
  def up
    rename_column :trigger_survey_triggers, :task_id, :tile_id
    rename_column :trigger_demographic_triggers, :task_id, :tile_id
    rename_column :trigger_rule_triggers, :task_id, :tile_id
  end

  def down
    rename_column :trigger_survey_triggers, :tile_id, :task_id
    rename_column :trigger_demographic_triggers, :tile_id, :task_id
    rename_column :trigger_rule_triggers, :tile_id, :task_id
  end
end
