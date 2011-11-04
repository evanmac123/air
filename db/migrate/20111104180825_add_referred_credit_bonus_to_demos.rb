class AddReferredCreditBonusToDemos < ActiveRecord::Migration
  def self.up
    add_column :demos, :referred_credit_bonus, :integer
  end

  def self.down
    remove_column :demos, :referred_credit_bonus
  end
end
