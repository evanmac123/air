class AddIntervalToCustSuccessKpis < ActiveRecord::Migration
  def change
    add_column :cust_success_kpis, :interval, :string
  end
end
