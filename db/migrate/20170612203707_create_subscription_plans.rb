class CreateSubscriptionPlans < ActiveRecord::Migration
  def change
    create_table :subscription_plans do |t|
      t.string :name
      t.integer :interval_count, default: 1
      t.integer :interval_cd, default: 0

      t.timestamps
    end
  end
end
