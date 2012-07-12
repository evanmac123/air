class AddGoldCoinCointToUsers < ActiveRecord::Migration
  def up
    add_column :users, :gold_coins, :integer
    execute "UPDATE users SET gold_coins = 0"
    change_column :users, :gold_coins, :integer, :default => 0, :null => false
  end

  def down
    remove_column :users, :gold_coins
  end
end
