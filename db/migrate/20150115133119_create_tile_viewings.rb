class CreateTileViewings < ActiveRecord::Migration
  def change
    create_table :tile_viewings do |t|
      t.integer :tile_id
      t.integer :user_id
      t.string :user_type
      t.integer :views, default: 1

      t.timestamps
    end
  end
end
