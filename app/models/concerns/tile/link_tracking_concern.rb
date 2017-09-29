module Tile::LinkTrackingConcern
  TILE_LINK_TRACKING_RELEASE_DATE = "2017-09-28".to_date

  def track_link_click(clicked_link:, user:)
    if new_unique_link_click?(clicked_link, user.id)
      increment_unique_link_clicks_by_link(clicked_link)
    end

    increment_link_clicks_by_link(clicked_link)
  end

  def new_unique_link_click?(clicked_link, user_id)
    rdb[:unique_link_click_users][clicked_link].sadd(user_id) == 1
  end

  def unique_users_who_clicked(link)
    rdb[:unique_link_click_users][link].smembers
  end

  def increment_unique_link_clicks_by_link(link)
    rdb[:unique_link_clicks].zincrby(1, link)
  end

  def increment_link_clicks_by_link(link)
    rdb[:link_clicks].zincrby(1, link)
  end

  def unique_link_clicks_by_link
    rdb[:unique_link_clicks].zrangebyscore("-inf", "inf", "WITHSCORES").reverse
  end

  def link_clicks_by_link
    rdb[:link_clicks].zrangebyscore("-inf", "inf", "WITHSCORES").reverse
  end

  def raw_link_click_stats
    {
      unique_link_clicks: unique_link_clicks_by_link,
      link_clicks: link_clicks_by_link
    }
  end

  def link_click_stats(link_data: {})
    raw_link_click_stats.each do |measure, data|
      data.each_slice(2) do |click_count, link|
        link_data[link] ||= {}
        link_data[link][measure] = click_count.to_i
      end
    end

    link_data
  end

  def has_link_tracking?
    activated_at.present? && activated_at >= TILE_LINK_TRACKING_RELEASE_DATE
  end
end
