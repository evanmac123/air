class ChangeEstimateOnContacts < ActiveRecord::Migration
  def change
      remove_column :contracts, :estimate_type 
      remove_column :contracts, :is_upgrade 
      add_column :contracts, :is_actual, :boolean, default: true
  end

end
