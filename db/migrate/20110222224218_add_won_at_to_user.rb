class AddWonAtToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :won_at, :datetime
  end

  def self.down
    remove_column :users, :won_at
  end
end
