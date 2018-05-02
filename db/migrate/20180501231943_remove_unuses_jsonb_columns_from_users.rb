class RemoveUnusesJsonbColumnsFromUsers < ActiveRecord::Migration
  def up
    remove_index :users, :population_segments
    remove_column :users, :population_segments

    remove_index :users, :segments
    remove_column :users, :segments
  end

  def down
    add_column :users, :population_segments, :jsonb, default: '{}'
    add_index  :users, :population_segments, using: :gin
    add_column :users, :segments, :jsonb, default: '{}'
    add_index  :users, :segments, using: :gin
  end
end
