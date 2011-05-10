class RenamedClosedAtToCloseAt < ActiveRecord::Migration
  def self.up
    rename_column :surveys, :closed_at, :close_at
  end

  def self.down
    rename_column :surveys, :close_at, :closed_at
  end
end
