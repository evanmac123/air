class AddReportDateToMetrics < ActiveRecord::Migration
  def change
    add_column :metrics, :report_date, :date
  end
end
