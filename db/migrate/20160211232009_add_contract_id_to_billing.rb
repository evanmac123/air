class AddContractIdToBilling < ActiveRecord::Migration
  def change
    add_column :billings, :contract_id, :integer
  end
end
