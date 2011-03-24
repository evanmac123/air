class AddReferralPointsToRule < ActiveRecord::Migration
  def self.up
    add_column :rules, :referral_points, :integer
  end

  def self.down
    remove_column :rules, :referral_points
  end
end
