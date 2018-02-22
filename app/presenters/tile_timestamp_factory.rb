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
    if tile.is_fully_assembled?
      timestamp_html
    else
      incomplete_timestamp_html
    end
  end

  private

    def timestamp_html
      "<div class='activation_dates'><span><i class='fa fa-#{icon}'></i>#{time}</span></div>".html_safe
    end

    def incomplete_timestamp_html
      "<div class='activation_dates incomplete'><span><i class='fa fa-cog'></i>Incomplete</span></div>".html_safe
    end

    def time_in_format(time)
      time.strftime("%-m/%-d/%Y")
    end

    def icon
      case tile.status.to_sym
      when :user_submitted, :plan, :draft
        "clock-o"
      when :active, :archive, :ignored
        "calendar"
      end
    end

    def time
      case tile.status.to_sym
      when :ignored
        time_in_format(tile.created_at)
      when :user_submitted, :plan, :draft
        "#{distance_of_time_in_words(tile.created_at, Time.current)}"
      when :active, :archive
        time_in_format(tile.activated_at)
      end
    end
end
