class TileTag < ActiveRecord::Base
  has_many :tile_taggings, dependent: :destroy
  has_many :tiles, through: :tile_taggings

  has_alphabetical_column :title

  def self.with_public_tiles
    # There might be better way to do this, via a combination of JOIN and
    # DISTINCT, but I can't seem to browbeat ActiveRelation into doing that

    ids_from_taggings = TileTagging.joins(:tile).where("tiles.is_public" => true).pluck(:tile_tag_id)
    where(id: ids_from_taggings)
  end
end
