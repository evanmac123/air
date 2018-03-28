# frozen_string_literal: true

module TilesHelper
  def tile_class(tile)
    (@show_completed_tiles == true) || current_user.tile_completions.where(tile_id: tile.id).exists? ? "completed" : "not_completed"
  end

  def tile_id(tile)
    if tile.present?
      tile.id
    end
  end

  # nil is definitely not a url
  # with dots
  # without spaces
  # have at least one letter
  # no two dots together
  # starts with letter, ends with not dot
  def is_url?(str)
    !str.nil? && \
    str.include?(".") && \
    !str.include?(" ") && \
    str[/[a-zA-Z]+/] && \
    !str[/\.{2,}/] && \
    str[/^[\w].*[^.]$/]
  end

  def make_full_url(str)
    if is_url? str
      (str.start_with?("http://", "https://") ? "" : "http://") + str
    else
      str
    end
  end

  def all_tiles_done_link
    if params[:public_slug] || current_user.is_a?(GuestUser)
      slug = params[:public_slug] || current_user.demo.public_slug
      public_activity_path(slug)
    else
      activity_path(board_id: current_user.demo_id)
    end
  end

  def all_tiles_done_link_text
    "Return to homepage"
  end

  def tile_completed?(tile, execute_query = true)
    if execute_query
      @tile_completions ||= current_user.tile_completions.pluck(:tile_id)
      @tile_completions.include?(tile.id)
    end
  end

  def display_tile_for_search(tile)
    if do_not_display_unanswered_archived_tiles(tile)
      false
    else
      true
    end
  end

  def do_not_display_unanswered_archived_tiles(tile)
    current_user.end_user? && tile.archive? && !tile_completed?(tile)
  end

  def render_campaign_strip(presenter:)
    if presenter.class == SingleAdminTilePresenter
      color = presenter.tile.campaign.try(:color) || "#ffffff"
      content_tag(:div, nil, style: "height: 3px; background-color: #{color};")
    end
  end
end
