# This is the base class for creating the tile interaction section of the tile
# preview or live tile.
#
# It inherits from BasePresenter which has access to the view_context and all
# functionality available to the views (html helpers/ URL helpers etc)
#
# Tile interactions (buttons and other form elements) come in 3 flavors:
# 1. PreviewInteraction:  this is triggered from client admin dashboard, explore etc. The
# buttons and form elements are active but only simulate what happens when
# completing the tile.
# 2. UserCompletableInteraction: This is is the full size tile that end user see. The buttons/interactions
# re active and clicking them will complete the tile.
# 3. UserCompletedInteraction: The buttons and form elements are disabled and
# show the final state after the user has completed the tile.
#
# NOTE The different behaviors for each mode is driven by the javascript that
# is aware of the different data-attributes, css and markup for each
# interaction type.!
#
# NOTE UserCompletableInteraction currently uses the exact same markup as the
# PreviewInteraction. The separate class is preserved in case of future
# customization and to highlight that the modes are technically different.
#

# NOTE maybe a better name is TileInteractionMode?

class TileInteraction < BasePresenter
  attr_reader :tile, :user

  def initialize tile, context, user, completion=nil
    super(tile, context, {})
    @tile = tile
    @user = user
    @completion = completion
  end

  # Interactions are further classified into groups according  their customized behavior and complexity e.g.
  # free_response, custom_form, etc.!
  #
  # Each interaction mode e.g. PreviewInteraction,
  # implements its own version off the group behavior
  #
  # NOTE this group functionality can could be further refactored into separate
  # classes
  #
  def build
    subtype = tile.question_subtype

    answers = if subtype == "free_response"
                free_response_answer_group
              elsif subtype == "custom_form"
                custom_form_answer_group
              else
                standard_answer_group
              end

    answers.html_safe
  end

  def default_answer_buttons
    buttons =""
    index = nil
    tile.multiple_choice_answers.each_with_index do |answer, answer_index|
      buttons += content_tag :div, class: "js-tile-answer-container" do
        index = answer_index + 1
        btn = tile_answer_button answer, answer_index
        btn += content_tag(:div, "",  class: "answer_target", style: "display: none")
        btn
      end
    end
    [buttons, index]
  end

  protected

  def standard_answer_group
    raise "Implement in subclass"
  end

  def free_response_answer_group
    raise "Implement in subclass"
  end

  def custom_form_answer_group
    raise "Implement in subclass"
  end
end
