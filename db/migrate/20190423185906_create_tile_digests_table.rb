class CreateTileDigestsTable < ActiveRecord::Migration
  def change
    create_table :tile_digests do |t|
      t.references :demo, index: true, foreign_key: true
      t.date :planned

      t.timestamps null: false
    end
  end
end
