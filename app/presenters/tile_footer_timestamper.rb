module TileFooterTimestamper
  include ActionView::Helpers::DateHelper

  def footer_timestamp
    if tile.status == Tile::DRAFT
      spanned_text(
        "Created: " + tile.created_at.strftime('%-m/%-d/%Y'),
          "tile-created-at")
    elsif tile.status == Tile::USER_SUBMITTED
      spanned_text(
        "Submitted: " + tile.created_at.strftime('%-m/%-d/%Y'),
          "tile-submitted-at")
    elsif tile.activated_at.nil?
      spanned_text("Never activated")
    elsif tile.status == Tile::ARCHIVE
      if @format == :plain
        [
          active_time,
          "Deactivated: " + tile.archived_at.strftime('%-m/%-d/%Y')
        ].join(' ').html_safe
      else
        active_time
      end
    else
      if @format == :plain
        [
          active_time,
          "Since: " + tile.activated_at.strftime('%-m/%-d/%Y')
        ].join(' ')
      else
        active_time
      end
    end
  end

  protected

  def spanned_text(text, span_class = nil)
    return text unless @format == :html
    if span_class
      ["<span class='#{span_class}'>", text, "</span>"].join.html_safe
    else
      "<span>#{text}</span>".html_safe
    end
  end

  def active_time
    time_baseline = if tile.status == Tile::ARCHIVE
                      tile.archived_at
                    else
                      Time.now
                    end
    spanned_text(
      "Active: " + distance_of_time_in_words(tile.activated_at, time_baseline), 
      'tile-active-time')
  end

  attr_reader :tile
end
