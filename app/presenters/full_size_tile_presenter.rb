class FullSizeTilePresenter
  SAFE_NBSP = "&nbsp;".html_safe.freeze

  def initialize(tile, user, is_preview)
    @tile = tile
    @user = user
    @is_preview = is_preview
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

  def user_completed_tile_with_answer_index(answer_index)
    user_tile_completion.answer_index == answer_index
  end

  attr_reader :tile, :user, :is_preview

  protected

  def content_tag(*args)
    ActionController::Base.helpers.content_tag(*args).html_safe
  end

  def html_escape(*args)
    ERB::Util.h(*args)  
  end

  delegate :id, :image, :headline, :appears_client_created, :image_credit, :link_address, :points, :question, :multiple_choice_answers, :correct_answer_index, :is_survey?, :is_action?, :original_creator, :tile_completions, :human_original_creator_identification, :human_original_creation_date, to: :tile
end
