class CreateBlacklists < ActiveRecord::Migration
  def change
    create_table :blacklists do |t|
      t.integer :raffle_id
      t.integer :user_id

      t.timestamps
    end
  end
end
