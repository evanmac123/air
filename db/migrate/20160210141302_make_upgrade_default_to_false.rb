class MakeUpgradeDefaultToFalse < ActiveRecord::Migration
  def change
  change_column :contracts, :is_upgrade, :boolean, default: false
  end
end
