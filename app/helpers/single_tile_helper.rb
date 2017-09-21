module SingleTileHelper
  def single_tile_more_content_url(tile:)
    if current_user.is_a?(User)
      root_url(utm_source: "explore_single_tile", utm_campaign: tile.headline)
    else
      marketing_site_home_url(utm_source: "explore_single_tile", utm_campaign: tile.headline)
    end
  end

  def path_for_single_tile(tile:, source:)
    if source == :explore
      explore_tile_preview_url(tile)
    else
      sharable_tile_url(tile)
    end
  end

  def path_for_single_tile_with_tracking(tile:, source:)
    if source == :explore
      explore_tile_preview_url(tile, utm_source: "explore_single_tile", utm_campaign: tile.headline)
    else
      sharable_tile_url(tile, utm_source: "public_single_tile", utm_campaign: tile.headline)
    end
  end

  def single_tile_logo(tile:)
    demo = tile.demo

    if demo && demo.logo.present?
      demo.logo
    else
      "airbo_logo_lightblue.png"
    end
  end

  def single_tile_is_explore(source:)
    source == :explore
  end

  def single_tile_is_public(source:)
    source == :public
  end

  def single_tile_hashtags(tile:)
    ["airbo"]
  end
end
