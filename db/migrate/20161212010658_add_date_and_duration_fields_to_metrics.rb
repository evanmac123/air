class AddDateAndDurationFieldsToMetrics < ActiveRecord::Migration
  def change
    add_column :metrics, :from, :date
    add_column :metrics, :to, :date
    add_column :metrics, :range, :string
    remove_column :metrics, :weekending_date
    remove_column :metrics, :report_date
  end
end
