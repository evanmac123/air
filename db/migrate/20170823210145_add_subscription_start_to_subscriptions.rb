class AddSubscriptionStartToSubscriptions < ActiveRecord::Migration
  def change
    add_column :subscriptions, :subscription_start, :datetime
  end
end
