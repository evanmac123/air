class CreateTriggerDemographicTriggers < ActiveRecord::Migration
  def self.up
    create_table :trigger_demographic_triggers do |t|
      t.belongs_to :suggested_task
      t.timestamps
    end

    add_index :trigger_demographic_triggers, :suggested_task_id
  end

  def self.down
    drop_table :trigger_demographic_triggers
  end
end
