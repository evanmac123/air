class AddVictoryThresholdToDemo < ActiveRecord::Migration
  def self.up
    add_column :demos, :victory_threshold, :integer
  end

  def self.down
    remove_column :demos, :victory_threshold
  end
end
