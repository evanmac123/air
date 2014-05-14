class CreateUsersInRaffles < ActiveRecord::Migration
  def change
    create_table :users_in_raffles do |t|
      t.integer :user_id
      t.integer :raffle_id
      t.boolean :start_showed
      t.boolean :finish_showed
      t.boolean :in_blacklist
      t.boolean :is_winner

      t.timestamps
    end
  end
end
