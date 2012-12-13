class ChangeGoldCoinsToTickets < ActiveRecord::Migration
  def change
    rename_column :demos, :uses_gold_coins, :uses_tickets
    rename_column :demos, :gold_coin_threshold, :ticket_threshold
    rename_column :demos, :minimum_gold_coin_award, :minimum_ticket_award
    rename_column :demos, :maximum_gold_coin_award, :maximum_ticket_award
    rename_column :users, :gold_coins, :tickets
  end
end
