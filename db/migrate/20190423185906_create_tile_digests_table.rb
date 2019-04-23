class CreateTileDigestsTable < ActiveRecord::Migration
  def change
    create_table :tiles_digest_buckets do |t|
      t.references :demo, index: true, foreign_key: true
      t.references :tiles_digest, index: true, foreign_key: true
      t.date :planned

      t.timestamps null: false
    end
  end
end
