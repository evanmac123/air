class RemoveColumnsFromCustSuccessKpi < ActiveRecord::Migration
  def up

     remove_column :cust_success_kpis, :percent_paid_orgs_added_a_tile
     remove_column :cust_success_kpis, :tiles_added_by_paid_client_admins
     remove_column :cust_success_kpis, :paid_orgs_that_added_a_tile
     remove_column :cust_success_kpis, :percent_added_tiles_copied_from_explore
     remove_column :cust_success_kpis, :percent_added_tiles_created_from_scratch
     remove_column :cust_success_kpis, :orgs_that_created_tiles_from_scratch
     remove_column :cust_success_kpis, :average_tiles_created_from_scratch_per_org_that_created
  end

  def down
    add_column :cust_success_kpis, :percent_paid_orgs_added_a_tile, :float
    add_column :cust_success_kpis, :tiles_added_by_paid_client_admins, :integer
    add_column :cust_success_kpis, :paid_orgs_that_added_a_tile, :integer
    add_column :cust_success_kpis, :percent_added_tiles_copied_from_explore, :float
    add_column :cust_success_kpis, :percent_added_tiles_created_from_scratch, :float
    add_column :cust_success_kpis, :orgs_that_created_tiles_from_scratch, :integer
    add_column :cust_success_kpis, :average_tiles_created_from_scratch_per_org_that_created, :float
  end
end
