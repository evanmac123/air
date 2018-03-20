# frozen_string_literal: true

class Campaign < ActiveRecord::Base
  belongs_to :demo
  has_many :campaign_tiles, dependent: :destroy
  has_many :tiles, through: :campaign_tiles

  validates :name, presence: true

  before_save :update_slug

  searchkick default_fields: [:name, :tile_headlines, :tile_content]

  def self.public_explore
    where(public_explore: true)
  end

  def self.private_explore(demo:)
    org = demo.try(:organization)

    if org.present?
      org.campaigns.where(private_explore: true)
    else
      Campaign.none
    end
  end

  def self.viewable_by_id(id:, demo:)
    Campaign.public_explore.find_by(id: id) || Campaign.private_explore(demo: demo).find(id)
  end

  def display_tiles
    if public_explore
      explore_tiles
    elsif private_explore
      active_tiles
    end
  end

  def active_tiles
    tiles.active.ordered_by_position
  end

  def explore_tiles
    active_tiles.where(is_public: true)
  end

  def search_data
    extra_data = {
      tile_headlines: tiles.pluck(:headline),
      tile_content: tiles.pluck(:supporting_content)
    }

    serializable_hash.merge(extra_data)
  end

  def update_slug
    self.slug = name.parameterize
  end

  def to_param
    [id, name.parameterize].join("-")
  end
end
