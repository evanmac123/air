class Channel < ActiveRecord::Base
  before_save :update_slug
  validates :name, uniqueness: true, presence: true

  has_attached_file :image,
    {
      styles: { explore: "190x90#" },
      default_style: :explore,
    }

  scope :active, -> { where(active: true) }
  scope :active_ordered, -> { active.order("channels.rank DESC") }

  def self.display_channels(excluded_channels = nil)
    active_ordered.where(Channel.arel_table[:slug].not_eq(excluded_channels))
  end

  def to_param
    self.slug
  end

  def update_slug
    self.slug = name.parameterize
  end

  def tiles
    @tiles ||= Tile.copyable.tagged_with(self.name).uniq
  end
end
