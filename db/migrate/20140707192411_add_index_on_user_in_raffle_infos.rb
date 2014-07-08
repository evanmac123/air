class AddIndexOnUserInRaffleInfos < ActiveRecord::Migration
  def change
  	add_index :user_in_raffle_infos, [:user_id, :user_type, :raffle_id], :unique => true, name: "user_in_raffle"
  end
end
