class AddBookingFieldsToMetrics < ActiveRecord::Migration
  def change
    add_column :metrics, :added_customer_amt_booked, :decimal
    add_column :metrics, :renewal_amt_booked, :decimal
  end
end
