class AddToCustSuccessKpi < ActiveRecord::Migration
  def change
    add_column :cust_success_kpis, :percent_paid_orgs_view_tile_in_explore, :float
    add_column :cust_success_kpis, :paid_orgs_visited_explore, :integer
    add_column :cust_success_kpis, :total_tiles_viewed_in_explore_by_paid_orgs, :integer
    add_column :cust_success_kpis, :paid_client_admins_who_viewed_tiles_in_explore, :integer
    add_column :cust_success_kpis, :tiles_viewed_per_paid_client_admin, :integer


    add_column :cust_success_kpis, :percent_paid_orgs_added_a_tile, :float
    add_column :cust_success_kpis, :tiles_added_by_paid_client_admins, :integer
    add_column :cust_success_kpis, :paid_orgs_that_added_a_tile, :integer
    add_column :cust_success_kpis, :percent_added_tiles_copied_from_explore, :float
    add_column :cust_success_kpis, :percent_added_tiles_created_from_scratch, :float

    add_column :cust_success_kpis, :tiles_created_from_scratch, :integer
    add_column :cust_success_kpis, :orgs_that_created_tiles_from_scratch, :integer
    add_column :cust_success_kpis, :average_tiles_created_from_scratch_per_org_that_created, :float

  end
end
