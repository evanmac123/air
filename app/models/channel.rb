class Channel < ActiveRecord::Base
  before_save :update_slug

  has_attached_file :image,
    {
      styles: { explore: "190x90#" },
      default_style: :explore,
    }

  scope :active, -> { where(active: true) }

  def self.display_channels(exclude_ids = nil)
    exclude_ids ? active.where(Channel.arel_table[:id].not_eq(exclude_ids)) : active
  end

  def update_slug
    self.slug = name.parameterize
  end

  def tiles
    @tiles ||= Tile.copyable.tagged_with(self.name).order("tiles.updated_at DESC").uniq
  end
end
