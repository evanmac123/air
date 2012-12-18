class AddTicketThresholdBaseToUsers < ActiveRecord::Migration
  def change
    add_column :users, :ticket_threshold_base, :integer, :default => 0
  end
end
