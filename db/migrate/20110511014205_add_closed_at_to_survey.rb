class AddClosedAtToSurvey < ActiveRecord::Migration
  def self.up
    add_column :surveys, :closed_at, :datetime
    change_column_null :surveys, :closed_at, Time.now + 24.hours
  end

  def self.down
    remove_column :surveys, :closed_at
  end
end
