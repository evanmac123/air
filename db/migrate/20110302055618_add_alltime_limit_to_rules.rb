class AddAlltimeLimitToRules < ActiveRecord::Migration
  def self.up
    add_column :rules, :alltime_limit, :integer
  end

  def self.down
    remove_column :rules, :alltime_limit
  end
end
