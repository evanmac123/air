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
    case tile_type
    when :active
      [
        spanned_text(span_params),
        "Since: " + time_in_format(tile.archived_at)
      ].join(' ')
    when :archive
      [
        spanned_text(span_params),
        "Deactivated: " + time_in_format(tile.activated_at)
      ].join(' ')
    when :archive_never_activated
      spanned_text(span_params)
    else
      ''
    end
  end

  def timestamp_html
    if type? *html_allowed_types
      spanned_text span_params
    else
      ''
    end
  end

  def tile_type
    if type?(:archive) && tile.activated_at.nil?
      :archive_never_activated
    else
      type
    end
  end

  def html_allowed_types
    [:draft, :active, :archive, :user_submitted, :ignored]
  end

  def span_params
    case tile_type
    when :draft
      {
        title: "Created: ",
        time: time_in_format(tile.created_at),
        class: "tile-created-at"
      }
    when :active
      {
        title: "Active: ",
        time: distance_of_time_in_words(tile.activated_at, Time.now),
        class: 'tile-active-time'
      }
    when :archive
      {
        title: "Active: ",
        time: distance_of_time_in_words(tile.activated_at, tile.archived_at),
        class: 'tile-active-time'
      }
    when :archive_never_activated
      {
        title: "Never activated",
        time: "",
        class: nil
      }
    when :user_submitted
      {
        title: "Submitted: ",
        time: time_in_format(tile.created_at),
        class: "tile-submitted-at"
      }
    when :ignored
      {
        title: "Submitted: ",
        time: time_in_format(tile.created_at),
        class: "tile-submitted-at"
      }
    else
      {
        title: "",
        time: "",
        class: nil
      }
    end
  end

  def time_in_format(time)
    time.strftime('%-m/%-d/%Y')
  end

  def spanned_text(params)
    title, time, span_class = params.values_at(:title, :time, :class)
    text = title + time

    return text if @format == :plain

    if span_class
      ["<span class='#{span_class}'>", text, "</span>"].join.html_safe
    else
      "<span>#{text}</span>".html_safe
    end
  end
end
