class AddIndexToUsersGameReferrerId < ActiveRecord::Migration
  def change
    add_index :users, :game_referrer_id
  end
end
