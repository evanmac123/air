class CreateRaffleWinners < ActiveRecord::Migration
  def change
    create_table :raffle_winners do |t|
      t.integer :raffle_id
      t.integer :user_id

      t.timestamps
    end
  end
end
