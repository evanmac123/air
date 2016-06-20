class AddParentContractIdContract < ActiveRecord::Migration
  def change
    add_column :contracts, :parent_contract_id, :integer
  end

end
