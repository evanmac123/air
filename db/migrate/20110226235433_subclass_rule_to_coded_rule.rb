class SubclassRuleToCodedRule < ActiveRecord::Migration
  def self.up
    add_column :rules, :type, :string
    add_column :rules, :description, :string
  end

  def self.down
    remove_column :rules, :description
    remove_column :rules, :type
  end
end
