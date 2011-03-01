class AddSeedPointsAndWelcomeMessageToDemo < ActiveRecord::Migration
  def self.up
    add_column :demos, :seed_points, :integer, :default => 0
    add_column :demos, :custom_welcome_message, :string, :limit => 140
  end

  def self.down
    remove_column :demos, :custom_welcome_message
    remove_column :demos, :seed_points
  end
end
