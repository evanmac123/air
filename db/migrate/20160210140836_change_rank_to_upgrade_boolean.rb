class ChangeRankToUpgradeBoolean < ActiveRecord::Migration
  def change
    remove_column :contracts, :rank
    add_column :contracts, :is_upgrade, :boolean
  end

end
