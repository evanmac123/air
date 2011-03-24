class AddEndingTimeToDemo < ActiveRecord::Migration
  def self.up
    add_column :demos, :ends_at, :datetime
  end

  def self.down
    remove_column :demos, :ends_at
  end
end
