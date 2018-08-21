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
      query_request = raw_filter.split("=")[1] == "0" ? "IS NULL" : "= #{raw_filter.split("=")[1]}"
      query_statement = get_query_statement(raw_filter.split("=")[0], args[:status])
      result += "#{query_statement} #{query_request} AND "
    end.chomp(" AND ")
  end

  def self.get_query_statement(raw_statement, status)
    if (raw_statement == "year" || raw_statement == "month")
      "extract(#{raw_statement} from #{STATUS_DATE[status]})"
    else
      "campaign_id"
    end
  end
end
