module TileFooterTimestamper
  include ActionView::Helpers::DateHelper

  def footer_timestamp
    if @format == :html
      timestamp_html
    else
      timestamp_plain
    end
  end

  protected

  def timestamp_plain
    case get_tile_status
    when :active
      [
        spanned_text(span_params),
        "Since: " + time_in_format(tile.activated_at)
      ].join(' ')
    when :archive
      [
        spanned_text(span_params),
        "Deactivated: " + time_in_format(tile.archived_at)
      ].join(' ')
    when :archive_never_activated
      spanned_text(span_params)
    else
      ''
    end
  end

  def timestamp_html
    if tile_status_matches? *html_allowed_types
      spanned_text span_params
    else
      ''
    end
  end

  def get_tile_status
    if tile_status_matches?(:archive) && tile.activated_at.nil?
      :archive_never_activated
    else
      tile_status
    end
  end

  def html_allowed_types
    [:draft, :active, :archive, :user_submitted, :ignored]
  end

  def span_params
    case get_tile_status
    when :draft
      {
        title: "Created: ",
        icon: "calendar",
        time: time_in_format(tile.created_at),
        class: "tile-created-at"
      }
    when :active
      {
        title: "Active: ",
        icon: "clock-o",
        time: distance_of_time_in_words(tile.activated_at, Time.now),
        class: 'tile-active-time'
      }
    when :archive
      {
        title: "Active: ",
        icon: "clock-o",
        time: distance_of_time_in_words(tile.activated_at, tile.archived_at),
        class: 'tile-active-time'
      }
    when :archive_never_activated
      {
        title: "Never activated",
        icon: "clock-o",
        time: "0",
        class: ""
      }
    when :user_submitted
      {
        title: "Submitted: ",
        icon: "calendar",
        time: time_in_format(tile.created_at),
        class: "tile-submitted-at"
      }
    when :ignored
      {
        title: "Submitted: ",
        icon: "calendar",
        time: time_in_format(tile.created_at),
        class: "tile-submitted-at"
      }
    else
      {
        title: "",
        icon: "",
        time: "",
        class: ""
      }
    end
  end

  def time_in_format(time)
    time.strftime('%-m/%-d/%Y')
  end

  def spanned_text(params)
    title, time, span_class, icon = params.values_at(:title, :time, :class, :icon)

    if @format == :plain
      title + time
    else
      [
        "<span class='#{span_class}'>", 
          "<i class='fa fa-#{icon}'></i>",
          time, 
        "</span>"
      ].join.html_safe
    end
  end
end
