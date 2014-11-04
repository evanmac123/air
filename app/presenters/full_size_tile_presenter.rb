class FullSizeTilePresenter
  def initialize(tile)
    @tile = tile
  end

  def supporting_content
    return @supporting_content if @supporting_content

    paras = @tile.supporting_content.split("\n")
    dewhitespaced_paras = paras.map{|para| para =~ /^\s*$/ ? "&nbsp;".html_safe : para}
    p_tags = dewhitespaced_paras.map{|para| content_tag('p', para)}
    @supporting_content = p_tags.join.html_safe
  end

  attr_reader :tile

  protected

  def content_tag(*args)
    ActionController::Base.helpers.content_tag(*args).html_safe
  end

  delegate :id, :image, :headline, :appears_client_created, :image_credit, :link_address, :points, :question, :multiple_choice_answers, :correct_answer_index, :is_survey?, :is_action?, :original_creator, :tile_completions, :human_original_creator_identification, :human_original_creation_date, to: :tile
end
