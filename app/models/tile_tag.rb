class TileTag < ActiveRecord::Base
  has_many :tile_taggings, dependent: :destroy
  has_many :tiles, through: :tile_taggings
  belongs_to :topic
  before_validation :set_topic

  def self.alphabetical
    # We use the C collation because we want tags that start with an @ sign to
    # show up first.

    order '(title COLLATE "C")'
  end

  def self.with_public_non_draft_tiles
    # There might be better way to do this, via a combination of JOIN and
    # DISTINCT, but I can't seem to browbeat ActiveRelation into doing that

    ids_from_taggings = TileTagging.joins(:tile).where("tiles.is_public" => true, "tiles.status" => [Tile::ACTIVE, Tile::ARCHIVE]).pluck(:tile_tag_id)
    where(id: ids_from_taggings)
  end

  def self.tag_name_like(text)
    TileTag.where("title ILIKE ?", "%#{text}%")
  end

  def self.have_tag(text)
    TileTag.where("title ILIKE ?", "#{text}").first
  end

  def self.rearrange_by_other
    self.rearrange "Other"
  end

  def self.rearrange last_tag_name
    tags = self.all
    i = tags.index{|t| t.title == last_tag_name}
    if i
      last_tag = tags.delete_at(i)
      tags.push(last_tag)
    end
    tags
  end

  private

  def set_topic
    if topic.nil?
      self.topic = Topic.where(:name => "Other").first
    end
  end
end
