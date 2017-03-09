class Channel < ActiveRecord::Base
  before_save :update_slug
  validates :name, uniqueness: { case_sensitive: false }, presence: true

  has_attached_file :image,
    {
      styles: { explore: "190x90#" },
      default_style: :explore,
    }

  scope :active, -> { where(active: true) }
  scope :active_ordered, -> { active.order("channels.rank DESC").order(:name) }

  def self.display_channels(excluded_channels = nil)
    active_ordered.where(Channel.arel_table[:slug].not_eq(excluded_channels))
  end

  def to_param
    [id, name.parameterize].join("-")
  end

  def update_slug
    self.slug = name.parameterize
  end

  def tiles
    @tiles ||= Tile.explore_without_featured_tiles(related_features).tagged_with(self.name).uniq
  end

  def related_campaigns
    Campaign.tagged_with(self.name, on: :channels, any: true)
  end

  def related_features
    @related_features ||= TileFeature.tagged_with(self.name, on: :channels, any: true)
  end
end
