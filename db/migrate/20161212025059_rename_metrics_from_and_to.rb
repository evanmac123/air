class RenameMetricsFromAndTo < ActiveRecord::Migration
  def  change
    rename_column :metrics, :from, :from_date
    rename_column :metrics, :to, :to_date
  end

end
