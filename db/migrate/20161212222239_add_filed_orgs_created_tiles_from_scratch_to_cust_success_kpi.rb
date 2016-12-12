class AddFiledOrgsCreatedTilesFromScratchToCustSuccessKpi < ActiveRecord::Migration
  def change
    add_column :cust_success_kpis, :orgs_that_created_tiles_from_scratch, :integer
    add_column :cust_success_kpis, :average_tiles_created_from_scratch_per_org_that_created, :integer
  end
end
