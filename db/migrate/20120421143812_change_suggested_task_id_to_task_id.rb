class ChangeSuggestedTaskIdToTaskId < ActiveRecord::Migration
  def self.up
    remove_index :prerequisites, :suggested_task_id
    remove_index :task_suggestions, :suggested_task_id
    remove_index :trigger_demographic_triggers, :suggested_task_id
    remove_index :trigger_rule_triggers, :suggested_task_id
    remove_index :trigger_survey_triggers, :suggested_task_id
    
    rename_column :prerequisites, :suggested_task_id, :task_id
    rename_column :task_suggestions, :suggested_task_id, :task_id
    rename_column :trigger_demographic_triggers, :suggested_task_id, :task_id
    rename_column :trigger_rule_triggers, :suggested_task_id, :task_id
    rename_column :trigger_survey_triggers, :suggested_task_id, :task_id
    
    add_index :prerequisites, :task_id
    add_index :task_suggestions, :task_id
    add_index :trigger_demographic_triggers, :task_id
    add_index :trigger_rule_triggers, :task_id
    add_index :trigger_survey_triggers, :task_id
    
  end

  def self.down
    remove_index :prerequisites, :task_id
    remove_index :task_suggestions, :task_id
    remove_index :trigger_demographic_triggers, :task_id
    remove_index :trigger_rule_triggers, :task_id
    remove_index :trigger_survey_triggers, :task_id
    
    rename_column :prerequisites, :task_id, :suggested_task_id
    rename_column :task_suggestions, :task_id, :suggested_task_id
    rename_column :trigger_demographic_triggers, :task_id, :suggested_task_id
    rename_column :trigger_rule_triggers, :task_id, :suggested_task_id
    rename_column :trigger_survey_triggers, :task_id, :suggested_task_id    
    
    add_index :prerequisites, :suggested_task_id
    add_index :task_suggestions, :suggested_task_id
    add_index :trigger_demographic_triggers, :suggested_task_id
    add_index :trigger_rule_triggers, :suggested_task_id
    add_index :trigger_survey_triggers, :suggested_task_id
  end
end
