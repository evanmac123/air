# frozen_string_literal: true

class FullSizeTilePresenter
  include ApplicationHelper
  SAFE_NBSP = "&nbsp;".html_safe.freeze

  attr_reader :tile, :user, :is_preview, :browser
  delegate :id,
    :demo,
    :image,
    :headline,
    :image_credit,
    :points,
    :question,
    :multiple_choice_answers,
    :correct_answer_index,
    :is_survey?,
    :is_action?,
    :original_creator,
    :tile_completions,
    :embed_video,
    :question_type,
    :question_subtype,
    :allow_free_response?,
    :is_anonymous,
    :is_anonymous?,
    :question_config,
    :documents,
    :is_sharable,
    :is_public,
    to: :tile

  def initialize(tile, user, is_preview, current_tile_ids, browser)
    @tile = tile
    @user = user
    @is_preview = is_preview
    @current_tile_ids = current_tile_ids
    @browser = browser
  end

  def storage_key
    "progress.#{demo ? demo.id : 1099}.#{id}"
  end

  def supporting_content
    return @supporting_content if @supporting_content

    lines = @tile.supporting_content.split("\n")
    unemptied_lines = lines.map { |line| line =~ /^\s*$/ ? SAFE_NBSP : line }
    p_tags = unemptied_lines.map { |line| content_tag("p", line) }
    @supporting_content = p_tags.join.html_safe
  end


  def current_tile_ids_joined
    @current_tile_ids && @current_tile_ids.join(",")
  end

  def adjacent_tile_image_urls
    Tile.where(id: adjacent_tile_ids).map { |tile| ActionController::Base.helpers.image_path(tile.image.url) }
  end

  def show_video?
    tile.embed_video.present?
  end

  def has_ribbon_tag?
    if ribbon_tag = tile.ribbon_tag
      @ribbon_tag_name = ribbon_tag.name
      @ribbon_tag_color = ribbon_tag.color
      true
    else
      false
    end
  end

  def ribbon_tag_name
    @ribbon_tag_name ||= tile.ribbon_tag.name
  end

  def ribbon_tag_color
    @ribbon_tag_color ||= tile.ribbon_tag.color
  end

  def ribbon_tag_font_color
    hex = if @ribbon_tag_color.length == 7
      @ribbon_tag_color[1..-1]
    else
      @ribbon_tag_color[1] + @ribbon_tag_color[1] + @ribbon_tag_color[2] + @ribbon_tag_color[2] + @ribbon_tag_color[3] + @ribbon_tag_color[3]
    end
    red = Integer(hex[0..1], 16)
    green = Integer(hex[2..3], 16)
    blue = Integer(hex[4..5], 16)
    (red * 0.299 + green * 0.587 + blue * 0.114) > 186 ? "#000000" : "#FFFFFF"
  end

  private

    def adjacent_tile_ids
      return [] unless @current_tile_ids.present?

      current_tile_index = @current_tile_ids.index(tile.id)
      return [] unless current_tile_index

      adjacent_indices = [1, -1].map do |offset|
        (current_tile_index + offset) % @current_tile_ids.length
      end

      adjacent_indices.map { |adjacent_index| @current_tile_ids[adjacent_index] }
    end

    def content_tag(*args, &block)
      ActionController::Base.helpers.content_tag(*args, &block).html_safe
    end

    def html_escape(*args)
      ERB::Util.h(*args)
    end
end
