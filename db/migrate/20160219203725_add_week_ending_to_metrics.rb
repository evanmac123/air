class AddWeekEndingToMetrics < ActiveRecord::Migration
  def change
    add_column :metrics, :weekending_date, :date
  end
end
