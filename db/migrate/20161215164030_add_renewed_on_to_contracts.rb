class AddRenewedOnToContracts < ActiveRecord::Migration
  def change
    add_column :contracts, :renewed_on, :date
  end
end
