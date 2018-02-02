# frozen_string_literal: true

module ExploreHelper
  def explore_campaign_nav_link_image
    Tile.explore.offset(10).first.try(:thumbnail)
  end
end
