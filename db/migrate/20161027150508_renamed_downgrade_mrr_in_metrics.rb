class RenamedDowngradeMrrInMetrics < ActiveRecord::Migration
  def up
    rename_column :metrics, :downgrade_mmr, :downgrade_mrr
  end

  def down
    rename_column :metrics, :downgrade_mrr, :downgrade_mmr
  end
end
