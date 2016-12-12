class ChangeContractMoneyFieldsToInt < ActiveRecord::Migration
  def up
    change_column :contracts, :arr, :integer
    change_column :contracts, :mrr, :integer
    change_column :contracts, :amt_booked, :integer
  end

  def down
  end
end
