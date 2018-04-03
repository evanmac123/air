class AddsSegmentsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :segments, :jsonb, default: '{}'
    add_index  :users, :segments, using: :gin
  end
end
