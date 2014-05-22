class CreateUserInRaffleInfos < ActiveRecord::Migration
  def change
    create_table :user_in_raffle_infos do |t|
      t.integer :user_id
      t.integer :raffle_id
      t.boolean :start_showed, default: false, :null => false
      t.boolean :finish_showed, default: false, :null => false
      t.boolean :in_blacklist, default: false, :null => false
      t.boolean :is_winner, default: false, :null => false

      t.timestamps
    end
    add_index :user_in_raffle_infos, [:user_id, :raffle_id], :unique => true
  end
end
