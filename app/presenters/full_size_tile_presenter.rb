class FullSizeTilePresenter
  include ApplicationHelper
  SAFE_NBSP = "&nbsp;".html_safe.freeze

  attr_reader :tile, :user, :is_preview, :browser
  delegate :id,
    :demo,
    :image,
    :headline,
    :image_credit,
    :link_address,
    :points,
    :question,
    :multiple_choice_answers,
    :correct_answer_index,
    :is_survey?,
    :is_action?,
    :original_creator,
    :tile_completions,
    :full_size_image_height,
    :custom_supporting_content_class,
    :embed_video,
    :question_type,
    :question_subtype,
    :allow_free_response?,
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

  def non_preview_of_completed_tile?
    !is_preview && user_completed_tile?
  end

  def user_completed_tile?
    user_tile_completion.present?
  end

  def user_tile_completion
    # nil is a valid answer, so we have to remember if this is memoized separately
    return @user_tile_completion if @user_tile_completion_memoized
    @user_tile_completion_memoized = true
    @user_tile_completion = @user.tile_completions.where(tile_id: tile.id).first
  end

  def is_possible_correct_answer?(answer_index)
    answer_index == tile.correct_answer_index || tile.is_survey? || tile.is_action?
  end

  def is_invitation_answer?(answer_index)
    answer_index == tile.correct_answer_index &&
    tile.question_subtype == Tile::INVITE_SPOUSE
  end

  def is_change_email_answer?(answer_index)
    answer_index == tile.correct_answer_index &&
    tile.question_subtype == Tile::CHANGE_EMAIL
  end

  def action_answer_class(answer_index)
    if is_invitation_answer?(answer_index) && user.is_a?(User)
      'invitation_answer'
    elsif is_change_email_answer?(answer_index) && user.is_a?(User)
      'change_email_answer'
    else
      ''
    end
  end

  def user_completed_tile_with_answer_index(answer_index)
    user_tile_completion.answer_index == answer_index
  end

  def current_tile_ids_joined
    @current_tile_ids && @current_tile_ids.join(',')
  end

  def adjacent_tile_image_urls
    Tile.where(id: adjacent_tile_ids).map{|tile| tile.image.url}
  end

  def free_form_response
    user_tile_completion && user_tile_completion.free_form_response
  end

  def image_styles
    styles = ""
    styles += (is_preview || ie9_or_older?) ? "height:#{full_size_image_height}px;" : ""
    # styles += "display:#{show_image? ? 'none' : 'block'};"
    styles
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

  def content_tag(*args)
    ActionController::Base.helpers.content_tag(*args).html_safe
  end

  def html_escape(*args)
    ERB::Util.h(*args)
  end
end
