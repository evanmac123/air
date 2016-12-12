class AddTilesAddedFieldsToCustSuccessKpi < ActiveRecord::Migration
  def change
    add_column :cust_success_kpis, :total_tiles_added_by_paid_client_admin, :integer
    add_column :cust_success_kpis, :total_tiles_added_from_copy_by_paid_client_admin, :integer
    add_column :cust_success_kpis, :total_tiles_added_from_scratch_by_paid_client_admin, :integer
    add_column :cust_success_kpis, :percent_of_added_tiles_from_copy, :float
    add_column :cust_success_kpis, :percent_of_added_tiles_from_scratch, :float

    add_column :cust_success_kpis, :unique_orgs_that_added_tiles, :integer
    add_column :cust_success_kpis, :percent_orgs_that_added_tiles, :float
  end
end
