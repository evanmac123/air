class ChangeKpiAvgFieldsToFloat < ActiveRecord::Migration
  def up
    change_column :cust_success_kpis, :tiles_viewed_per_paid_client_admin, :float
    change_column :cust_success_kpis, :average_tiles_created_from_scratch_per_org_that_created, :float
  end

  def down
  end
end
