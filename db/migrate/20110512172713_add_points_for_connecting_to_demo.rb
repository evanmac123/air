class AddPointsForConnectingToDemo < ActiveRecord::Migration
  def self.up
    add_column :demos, :points_for_connecting, :integer
  end

  def self.down
    remove_column :demos, :points_for_connecting
  end
end
