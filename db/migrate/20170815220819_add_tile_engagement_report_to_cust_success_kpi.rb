class AddTileEngagementReportToCustSuccessKpi < ActiveRecord::Migration
  def change
    add_column :cust_success_kpis, :tile_completion_rate, :decimal
    add_column :cust_success_kpis, :tile_view_rate, :decimal
  end
end
