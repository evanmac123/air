class RemoveIndexUserInRaffleInfosOnUserIdAndRaffleId < ActiveRecord::Migration
  def change
  	remove_index(:user_in_raffle_infos, :name => 'index_user_in_raffle_infos_on_user_id_and_raffle_id')
  end
end
