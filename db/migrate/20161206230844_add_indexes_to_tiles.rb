class AddIndexesToTiles < ActiveRecord::Migration
  def change
    add_index :tiles, :demo_id
    add_index :tiles, :status
    add_index :tiles, :created_at
    add_index :tiles, :activated_at
    add_index :tiles, :archived_at
  end
end
