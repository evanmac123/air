class AddUniqOrgsThatViewedTilesInExploreToCustSuccessKpi < ActiveRecord::Migration
  def change
    add_column :cust_success_kpis, :unique_orgs_that_viewed_tiles_in_explore, :integer
  end
end
