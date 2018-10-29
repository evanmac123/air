# frozen_string_literal: true

module Tile::ReactProcessing
  STATUS_DATE = {
    "plan" => "plan_date",
    "active" => "activated_at",
    "archive" => "archived_at",
  }

  def self.get_query_statement(raw_statement, status)
    if (raw_statement == "year" || raw_statement == "month")
      "extract(#{raw_statement} from #{STATUS_DATE[status]})"
    else
      "campaign_id"
    end
  end

  def self.build_query(result, status, sort)
    type, query = sort
    unless type == "sortType"
      query_request = query == "0" ? "IS NULL" : "= #{query}"
      query_statement = get_query_statement(type, status)
      result += "#{query_statement} #{query_request} AND "
    else
      result
    end
  end

  def self.get_edit_tile_filters(args)
    filter = args[:filter].split("&") || []
    filter.reduce("") do |result, raw_filter|
      build_query(result, args[:status], raw_filter.split("="))
    end.chomp(" AND ")
  end

  def self.sanitize_sort_filter(split_raw_filter, direction, status)
    split_raw_filter.reduce("") do |result, raw_filter|
      type, query = raw_filter.split("=")
      if type == "sortType"
        query == "date-sort" ? "#{STATUS_DATE[status]} #{direction}" : "position DESC"
      else
        result
      end
    end
  end

  def self.get_edit_tile_sort(args)
    status = args[:status]
    direction = status == "active" || status == "archive" ? "DESC" : "ASC"
    sanitized_filter = sanitize_sort_filter(args[:filter].split("&"), direction, status)
    sanitized_filter.empty? ? "position DESC" : sanitized_filter
  end

  def self.sanitize_for_edit_flow(tiles, amount)
    Tile.react_sanitize(tiles, amount) do |tile|
      tile_id = tile.id
      {
        "tileShowPath" => "/client_admin/tiles/#{tile_id}",
        "editPath" => "/client_admin/tiles/#{tile_id}/edit",
        "headline" => tile.headline,
        "id" => tile_id,
        "thumbnail" => tile.thumbnail_url,
        "planDate" => tile.plan_date,
        "activeDate" => tile.activated_at,
        "archiveDate" => tile.archived_at,
        "fullyAssembled" => tile.is_fully_assembled?,
        "campaignColor" => tile.try(:campaign_color),
        "unique_views" => tile.unique_viewings_count,
        "views" => tile.total_viewings_count,
        "completions" => tile.tile_completions_count,
      }
    end
  end

  def self.sanitize_for_explore(tiles, amount)
    Tile.react_sanitize(tiles, amount) do |tile|
      id = tile.id
      {
        "copyPath" => "/explore/copy_tile?path=via_explore_page_tile_view&tile_id=#{id}",
        "tileShowPath" => "/explore/tile/#{id}",
        "headline" => tile.headline,
        "id" => id,
        "created_at" => tile.created_at,
        "thumbnail" => tile.thumbnail_url,
        "thumbnailContentType" => tile.thumbnail_content_type
      }
    end
  end

  def sanitize_for_tile_show
    {
      id: id,
      headline: headline,
      supportingContent: supporting_content,
      imagePath: image.url,
      embedVideo: embed_video,
      question: question,
      questionType: question_type,
      questionSubtype: question_subtype,
      answers: multiple_choice_answers,
      correctAnswerIndex: correct_answer_index,
      points: points,
      exploreSharePath: "/explore/tile/#{id}",
      sharablePath: "/tile/#{id}",
      attachments: documents,
      imageCredit: image_credit
    }
  end
end
