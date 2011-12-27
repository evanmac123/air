class CreateTriggerRuleTriggers < ActiveRecord::Migration
  def self.up
    create_table :trigger_rule_triggers do |t|
      t.belongs_to :rule
      t.belongs_to :suggested_task
      t.timestamps
    end

    add_index :trigger_rule_triggers, :rule_id
    add_index :trigger_rule_triggers, :suggested_task_id
  end

  def self.down
    drop_table :trigger_rule_triggers
  end
end
