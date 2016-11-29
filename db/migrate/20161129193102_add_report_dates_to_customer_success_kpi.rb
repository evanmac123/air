class AddReportDatesToCustomerSuccessKpi < ActiveRecord::Migration
  def change
    add_column :cust_success_kpis, :report_date, :date
    add_column :cust_success_kpis, :from_date, :date
    add_column :cust_success_kpis, :to_date, :date
  end
end
