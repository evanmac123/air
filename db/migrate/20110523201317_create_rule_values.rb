class CreateRuleValues < ActiveRecord::Migration
  def self.up
    create_table :rule_values do |t|
      t.string :value
      t.boolean :is_primary, :null => false, :default => false
      t.belongs_to :rule
      t.timestamps
    end

    add_index :rule_values, :rule_id
    add_index :rule_values, :is_primary

    ActiveRecord::Base.connection.execute("CREATE INDEX index_rule_values_value_tsvector ON rule_values USING gin(to_tsvector('english', value));")

    Rule.all.each do |rule|
      RuleValue.create!(:value => rule.value, :rule_id => rule.id)
    end

    remove_column :rules, :value
  end

  def self.down
    add_column :rules, :value, :string
    ActiveRecord::Base.connection.execute("CREATE INDEX index_rule_value_tsvector ON rules USING gin(to_tsvector('english', value));")

    Rule.reset_column_information

    RuleValue.all.each do |rule_value|
      rule = Rule.find(rule_value.rule_id)
      rule.value = rule_value.value
      rule.save!
    end

    drop_table :rule_values
  end
end
