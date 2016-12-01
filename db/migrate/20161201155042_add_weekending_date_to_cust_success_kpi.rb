class AddWeekendingDateToCustSuccessKpi < ActiveRecord::Migration
  def change
    add_column :cust_success_kpis, :weekending_date, :date
  end
end
