# frozen_string_literal: true

class Campaign < ActiveRecord::Base
  belongs_to :demo
  has_many :campaign_tiles
  has_many :tiles, through: :campaign_tiles

  validates :name, presence: true

  before_save :update_slug

  searchkick default_fields: [:name, :tile_headlines, :tile_content]

  def explore_tiles
    tiles.active.ordered_by_position.where(is_public: true)
  end

  def search_data
    {
      name: name,
      tile_headlines: tiles.pluck(:headline),
      tile_content: tiles.pluck(:supporting_content)
    }
  end

  def update_slug
    self.slug = name.parameterize
  end

  def to_param
    [id, name.parameterize].join("-")
  end
end
