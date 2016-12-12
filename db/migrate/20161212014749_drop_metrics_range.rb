class DropMetricsRange < ActiveRecord::Migration
  def change
    remove_column :metrics, :range
  end

end
