class TileFooterTimestamper
  include ActionView::Helpers::DateHelper

  def initialize(tile, options={})
    @tile   = tile
    @format = options[:format] || :html
  end

  def footer_timestamp
    if tile.status == Tile::DRAFT
      spanned_text(
        "Created: " + tile.created_at.strftime('%-m/%-d/%Y'),
          "tile-created-at")
    elsif
      tile.activated_at.nil?
      spanned_text("Never activated")
    elsif tile.status == Tile::ARCHIVE
      [
        active_time,
        spanned_text(
          "Deactivated: " + tile.archived_at.strftime('%-m/%-d/%Y'),
          'tile-deactivated-time')
      ].join(' ').html_safe
    else
      active_time
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
