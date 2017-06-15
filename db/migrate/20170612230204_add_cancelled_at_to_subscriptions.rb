class AddCancelledAtToSubscriptions < ActiveRecord::Migration
  def change
    add_column :subscriptions, :cancelled_at, :datetime
  end
end
