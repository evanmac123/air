class IncreaseLengthOfDescription < ActiveRecord::Migration
  def self.up
    change_column :suggested_tasks, :short_description, :text, :default => ""
    change_column :suggested_tasks, :long_description, :text, :default => ""
  end

  def self.down
    change_column :suggested_tasks, :short_description, :string, :default => ""
    change_column :suggested_tasks, :long_description, :string, :default => ""
  end
end
