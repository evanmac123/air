# frozen_string_literal: true

module ExploreHelper
  def explore_campaign_nav_link_image
    offset = rand(10) + 5
    Tile.explore.offset(offset).first.try(:thumbnail)
  end

  def campaign_nav_tile_image(campaign)
    tile = campaign.display_tiles.where.not(thumbnail_content_type: "image/gif").first

    tile.try(:thumbnail) || explore_campaign_nav_link_image
  end
end
