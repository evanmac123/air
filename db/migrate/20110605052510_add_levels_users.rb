class AddLevelsUsers < ActiveRecord::Migration
  def self.up
    create_table :levels_users, :id => false do |t|
      t.belongs_to :level
      t.belongs_to :user
    end
  end

  def self.down
    drop_table :levels_users
  end
end
