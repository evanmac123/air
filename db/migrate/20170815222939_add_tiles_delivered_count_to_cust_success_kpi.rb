class AddTilesDeliveredCountToCustSuccessKpi < ActiveRecord::Migration
  def change
    add_column :cust_success_kpis, :tiles_delivered_count, :integer
  end
end
