class AddPopulationSegmentsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :population_segments, :jsonb, default: '{}'
    add_index  :users, :population_segments, using: :gin
  end
end
