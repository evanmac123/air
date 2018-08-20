# frozen_string_literal: true

module Tile::ReactProcessing
  STATUS_DATE = {
    "plan" => "plan_date",
    "active" => "activated_at",
    "archive" => "archived_at",
  }

  def self.get_edit_tile_filters(args)
    filter = args[:filter] || ""
    filter.split("&").reduce("") do |result, raw_filter|
      result += "extract(#{raw_filter.split('=')[0]} from #{STATUS_DATE[args[:status]]}) = #{raw_filter.split("=")[1]} AND "
    end.chomp(" AND ")
  end
end
