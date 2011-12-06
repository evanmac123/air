class AddRankingsLastUpdatedAtColumnsToDemos < ActiveRecord::Migration
  def self.up
    add_column :demos, :total_user_rankings_last_updated_at, :datetime
    add_column :demos, :average_user_rankings_last_updated_at, :datetime
  end

  def self.down
    remove_column :demos, :average_user_rankings_last_updated_at
    remove_column :demos, :total_user_rankings_last_updated_at
  end
end
