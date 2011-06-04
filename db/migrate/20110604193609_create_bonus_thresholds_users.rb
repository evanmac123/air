class CreateBonusThresholdsUsers < ActiveRecord::Migration
  def self.up
    create_table :bonus_thresholds_users, :id => false do |t|
      t.belongs_to :user
      t.belongs_to :bonus_threshold
    end

    add_index :bonus_thresholds_users, :user_id
    add_index :bonus_thresholds_users, :bonus_threshold_id
  end

  def self.down
    drop_table :bonus_thresholds_users
  end
end
