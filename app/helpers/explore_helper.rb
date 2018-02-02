# frozen_string_literal: true

module ExploreHelper
  def explore_campaign_nav_link_image
    offset = rand(10) + 5
    Tile.explore.offset(offset).first.try(:thumbnail)
  end
end
