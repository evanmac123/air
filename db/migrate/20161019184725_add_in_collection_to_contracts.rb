class AddInCollectionToContracts < ActiveRecord::Migration
  def change
    add_column :contracts, :in_collection, :boolean, default: false
  end
end
