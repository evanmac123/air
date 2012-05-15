class AddedIdentifierToSuggestedTask < ActiveRecord::Migration
  def self.up
    add_column :suggested_tasks, :end_time, :datetime
    add_column :suggested_tasks, :identifier, :string
  end

  def self.down
    remove_columns :suggested_tasks, :end_time, :identifier
  end
end
