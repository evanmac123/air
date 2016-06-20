class AddCycleToContract < ActiveRecord::Migration
  def change
    add_column :contracts, :cycle, :string
  end
end
