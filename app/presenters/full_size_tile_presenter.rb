class FullSizeTilePresenter
  SAFE_NBSP = "&nbsp;".html_safe.freeze

  def initialize(tile)
    @tile = tile
  end

  def supporting_content
    return @supporting_content if @supporting_content

    lines = @tile.supporting_content.split("\n")
    nbsped_lines = lines.map{ |line| line.split(/ /).map{|line| html_escape(line) }.join(SAFE_NBSP).html_safe }
    unemptied_lines = nbsped_lines.map{|line| line =~ /^\s*$/ ? SAFE_NBSP : line}
    p_tags = unemptied_lines.map{|line| content_tag('p', line)}
    @supporting_content = p_tags.join.html_safe
  end

  attr_reader :tile

  protected

  def content_tag(*args)
    ActionController::Base.helpers.content_tag(*args).html_safe
  end

  def html_escape(*args)
    ERB::Util.h(*args)  
  end

  delegate :id, :image, :headline, :appears_client_created, :image_credit, :link_address, :points, :question, :multiple_choice_answers, :correct_answer_index, :is_survey?, :is_action?, :original_creator, :tile_completions, :human_original_creator_identification, :human_original_creation_date, to: :tile
end
