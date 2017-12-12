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
  validates_attachment_content_type :cover_image, content_type: /\Aimage\/.*\Z/

  default_scope order(:name)

  searchkick word_start: [:channel_list, :tile_headlines], callbacks: :async

  def search_data
    extra_data = {
      channel_list: channel_list,
      tile_headlines: tiles.pluck(:headline),
      tile_content: tiles.pluck(:supporting_content)
    }

    serializable_hash.merge(extra_data)
  end

  def self.exclude(excluded_campaigns)
    campaigns = Campaign.arel_table
    Campaign.where(campaigns[:id].not_in(excluded_campaigns))
  end

  def update_slug
    self.slug = name.parameterize
  end

  def tile_count
    active_tiles.count
  end

  def to_param
    [id, name.parameterize].join("-")
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
