# frozen_string_literal: true

class Campaign < ActiveRecord::Base
  belongs_to :demo
  belongs_to :population_segment
  has_many :tiles

  validates :name, presence: true
  validates_uniqueness_of :name, case_sensitive: false, scope: :demo_id
  before_validation :strip_whitespace

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

  def to_param
    [id, name.parameterize].join("-")
  end

  private

    def strip_whitespace
      self.name = self.name.try(:strip)
    end
end
