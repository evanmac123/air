class CreateBalances < ActiveRecord::Migration
  def change
    create_table :balances do |t|
      t.integer :amount, default: 0, null: false
      t.belongs_to :demo, null: false

      t.timestamps

    end

    add_index :balances, :demo_id
  end
end
