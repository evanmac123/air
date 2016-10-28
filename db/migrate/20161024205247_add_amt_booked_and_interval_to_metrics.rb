class AddAmtBookedAndIntervalToMetrics < ActiveRecord::Migration
  def change
    add_column :metrics,  :amt_booked, :decimal
    add_column :metrics, :interval, :string
  end
end
