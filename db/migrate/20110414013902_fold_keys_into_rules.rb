class FoldKeysIntoRules < ActiveRecord::Migration
  def self.up
    Rule.all.each do |rule|
      rule.update_attribute(:value, rule.full_name)
    end

    remove_column :rules, :key_id
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
