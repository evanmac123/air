class AddBeginsAtToDemo < ActiveRecord::Migration
  def self.up
    add_column :demos, :begins_at, :datetime
  end

  def self.down
    remove_column :demos, :begins_at
  end
end
