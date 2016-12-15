class AddIndexesToMetrics < ActiveRecord::Migration
  def change
    add_index :metrics, :from_date
    add_index :metrics, :to_date
    add_index :metrics, :interval
  end
end
