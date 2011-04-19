class AddTsVectorIndexToRuleValue < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.connection.execute("CREATE INDEX index_rule_value_tsvector ON rules USING gin(to_tsvector('english', value));")
  end

  def self.down
    ActiveRecord::Base.connection.execute("DROP INDEX index_rule_value_tsvector")
  end
end
