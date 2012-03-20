class AddCharacteristicsToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :characteristics, :text
  end

  def self.down
    remove_column :users, :characteristics
  end
end
