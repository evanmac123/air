# frozen_string_literal: true

class Campaign < ActiveRecord::Base
  before_save :update_slug
  validates :name, uniqueness: true, presence: true

  belongs_to :demo
  has_many :tiles, -> { explore_non_ordered.ordered_by_position }, through: :demo

  searchkick default_fields: [:name, :tile_headlines, :tile_content]

  def self.default_scope
    order(:name)
  end

  def search_data
    {
      name: name,
      tile_headlines: tiles.pluck(:headline),
      tile_content: tiles.pluck(:supporting_content)
    }
  end

  def self.exclude(excluded_campaigns)
    campaigns = Campaign.arel_table
    Campaign.where(campaigns[:id].not_in(excluded_campaigns))
  end

  def update_slug
    self.slug = name.parameterize
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
end
