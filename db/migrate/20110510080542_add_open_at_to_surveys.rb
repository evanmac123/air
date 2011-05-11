class AddOpenAtToSurveys < ActiveRecord::Migration
  def self.up
    add_column :surveys, :open_at, :datetime
    change_column_null :surveys, :open_at, false, Time.now
  end

  def self.down
    remove_column :surveys, :open_at
  end
end
