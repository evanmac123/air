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
    "progress.#{demo.id}.#{id}"
  end

  def supporting_content
    return @supporting_content if @supporting_content

    lines = @tile.supporting_content.split("\n")
    unemptied_lines = lines.map{|line| line =~ /^\s*$/ ? SAFE_NBSP : line}
    p_tags = unemptied_lines.map{|line| content_tag('p', line)}
    @supporting_content = p_tags.join.html_safe
  end


  def current_tile_ids_joined
    @current_tile_ids && @current_tile_ids.join(',')
  end

  def adjacent_tile_image_urls
    Tile.where(id: adjacent_tile_ids).map{|tile| tile.image.url}
  end

  def show_image?
    !show_video?
  end

  def show_video?
    tile.embed_video.present? && !old_browser?
  end

  def old_browser?
    browser.ie8?
  end

  def extracted_video_link
    Nokogiri::HTML::Document.parse( tile.embed_video).xpath("//iframe").attribute("src").value
  end

  protected

  def adjacent_tile_ids
    return [] unless @current_tile_ids.present?

    current_tile_index = @current_tile_ids.index(tile.id)
    return [] unless current_tile_index

    adjacent_indices = [1,-1].map do |offset|
      (current_tile_index + offset) % @current_tile_ids.length
    end

    adjacent_indices.map{|adjacent_index| @current_tile_ids[adjacent_index]}
  end

  def content_tag(*args, &block)
    ActionController::Base.helpers.content_tag(*args, &block).html_safe
  end

  def html_escape(*args)
    ERB::Util.h(*args)
  end
end
