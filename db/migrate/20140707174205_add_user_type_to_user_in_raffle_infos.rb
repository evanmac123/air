class AddUserTypeToUserInRaffleInfos < ActiveRecord::Migration
  def change
  	add_column :user_in_raffle_infos, :user_type, :string, default: "User"
  end
end
