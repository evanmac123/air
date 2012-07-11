class AddGoldCoinParametersToDemos < ActiveRecord::Migration
  def change
    add_column :demos, :uses_gold_coins, :boolean
    add_column :demos, :gold_coin_threshold, :integer
    add_column :demos, :minimum_gold_coin_award, :integer
    add_column :demos, :maximum_gold_coin_award, :integer
  end
end
