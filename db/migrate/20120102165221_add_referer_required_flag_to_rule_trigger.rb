class AddRefererRequiredFlagToRuleTrigger < ActiveRecord::Migration
  def self.up
    add_column :trigger_rule_triggers, :referrer_required, :boolean
    execute "UPDATE trigger_rule_triggers SET referrer_required=false"
    change_column :trigger_rule_triggers, :referrer_required, :boolean, :null => false, :default => false
    add_index :trigger_rule_triggers, :referrer_required
  end

  def self.down
    remove_column :trigger_rule_triggers, :referrer_required
  end
end
