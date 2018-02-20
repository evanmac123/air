# frozen_string_literal: true

class TileTimestampFactory
  include ActionView::Helpers::DateHelper

  def self.call(tile)
    TileTimestampFactory.new(tile).perform
  end

  attr_reader :tile

  def initialize(tile)
    @tile = tile
  end

  def perform
    return incomplete_timestamp_html unless tile.is_fully_assembled?

    case tile.status.to_sym
    when :user_submitted
      suggested_timestamp_html
    when :plan, :draft
      plan_timestamp
    when :active, :archive
      activated_timestamp_html
    end
  end

  private

    def timestamp_html(icon, text, custom_class = nil)
      "<div class='activation_dates #{custom_class}'><span><i class='fa fa-#{icon}'></i>#{text}</span></div>".html_safe
    end

    def plan_timestamp
      if tile.plan_date
        plan_timestamp_html
      else
        unscheduled_timestamp_html
      end
    end

    def plan_timestamp_html
      icon = "calendar-check-o"
      text = tile.plan_date.strftime("%-m/%-d/%Y")

      timestamp_html(icon, text)
    end

    def activated_timestamp_html
      icon = "calendar"
      text = tile.activated_at.strftime("%-m/%-d/%Y")

      timestamp_html(icon, text)
    end

    def suggested_timestamp_html
      icon = "clock-o"
      text = "#{distance_of_time_in_words(tile.created_at, Time.current)} ago"

      timestamp_html(icon, text)
    end

    def incomplete_timestamp_html
      icon = "cog"
      text = "Incomplete"
      custom_class = "incomplete"

      timestamp_html(icon, text, custom_class)
    end

    def unscheduled_timestamp_html
      icon = "calendar-times-o"
      text = "Unplanned"

      timestamp_html(icon, text)
    end
end
