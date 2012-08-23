class AddRuleValueIdToAct < ActiveRecord::Migration
  def change
    add_column :acts, :rule_value_id, :integer
    add_index :acts, :rule_value_id
  end
end
