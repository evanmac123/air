class AddDefaultsToDemos < ActiveRecord::Migration
  def up
    change_column :demos, :game_referrer_bonus, :integer, default: 5
    change_column :demos, :referred_credit_bonus, :integer, default: 2
    change_column :demos, :credit_game_referrer_threshold, :integer, default: 100000
  end

  def down
    change_column :demos, :game_referrer_bonus, :integer, default: nil
    change_column :demos, :referred_credit_bonus, :integer, default: nil
    change_column :demos, :credit_game_referrer_threshold, :integer, default: nil
  end
end
