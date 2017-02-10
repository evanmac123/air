class Campaign < ActiveRecord::Base
  before_save :update_slug
  validates :name, uniqueness: true, presence: true

  belongs_to :demo
  has_many :tiles, through: :demo
  acts_as_taggable_on :channels

  has_attached_file :cover_image,
    {
      styles: { explore: "190x90#" },
      default_style: :explore,
    }

  default_scope order(:name)

  def self.exclude(excluded_campaigns)
    campaigns = Campaign.arel_table
    Campaign.where(campaigns[:id].not_in(excluded_campaigns))
  end

  def update_slug
    self.slug = name.parameterize
  end

  def tile_count
    tiles.explore.count
  end

  def to_param
    self.slug
  end

  def related_channels
    Channel.where(slug: self.channel_list.map(&:parameterize))
  end

  def formatted_instructions
    instructions.split("\n")
  end

  def formatted_sources
    sources.split(",").map(&:strip).in_groups_of(2)
  end

  def active_tiles
    tiles.explore.active
  end
end
