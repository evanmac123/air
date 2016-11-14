class AddUpgradeAmtBookedToMetrics < ActiveRecord::Migration
  def change
    add_column :metrics, :upgrade_amt_booked, :decimal
  end
end
