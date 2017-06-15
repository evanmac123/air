class CreateSubscriptions < ActiveRecord::Migration
  def change
    create_table :subscriptions do |t|
      t.references :organization
      t.references :subscription_plan
      t.datetime :cancelled_at
      t.string :chart_mogul_uuid

      t.timestamps
    end
    add_index :subscriptions, :organization_id
    add_index :subscriptions, :subscription_plan_id
  end
end
