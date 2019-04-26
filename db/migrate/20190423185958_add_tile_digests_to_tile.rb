class AddTileDigestsToTile < ActiveRecord::Migration
  def change
    add_reference :tiles, :tiles_digest_bucket, index: true, foreign_key: true
  end
end
