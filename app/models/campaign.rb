# frozen_string_literal: true

class Campaign < ActiveRecord::Base
  belongs_to :demo
  belongs_to :population_segment
  has_many :tiles

  validates :name, presence: true
  validates_uniqueness_of :name, case_sensitive: false, scope: :demo_id
  before_validation :strip_whitespace

  searchkick default_fields: [:name, :tile_headlines, :tile_content]

  def self.public_private_explore(current_board)
    private_explore(demo: current_board).concat(public_explore.order(:name)).map do |camp|
      add_props = {
        "thumbnails" => camp.sanitize_thumbnails,
        "path" => Rails.application.routes.url_helpers.explore_campaign_path(camp)
      }
      camp.as_json["campaign"].merge(add_props)
    end
  end

  def self.public_explore
    where(public_explore: true)
    .includes(:tiles)
  end

  def self.private_explore(demo:)
    org = demo.try(:organization)

    if org.present?
      org.campaigns.where(private_explore: true).includes(:tiles)
    else
      Campaign.none
    end
  end

  def self.viewable_by_id(id:, demo:)
    Campaign.public_explore.find_by(id: id) || Campaign.private_explore(demo: demo).find(id)
  end

  def sanitize_thumbnails
    display_tiles.limit(3).map { |tile| ActionController::Base.helpers.image_path(tile.thumbnail) }
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
