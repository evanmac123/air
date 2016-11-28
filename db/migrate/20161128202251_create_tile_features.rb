class CreateTileFeatures < ActiveRecord::Migration
  def change
    create_table :tile_features do |t|
      t.integer :rank
      t.string :name

      t.timestamps
    end
  end
end
