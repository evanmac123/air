class AddsSegmentsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :segments, :jsonb, null: false, default: '{}'
    add_index  :users, :segments, using: :gin
  end
end
