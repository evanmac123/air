class UserCompletedInteraction < TileInteraction
  def standard_answer_group
    buttons, index = default_answer_buttons
    buttons += optional_free_response_text(index) if tile.allow_free_response?
    buttons
  end

  def free_response_answer_group
    content =""
    content += content_tag :p, completion_free_response,  class: "free-form-response read"
    content += content_tag :div, "Submit my answer", class: 'multiple-choice-answer clicked_right_answer'
    content
  end

  def custom_form_answer_group
    buttons, _IGNORE_ = default_answer_buttons
    buttons
  end

  def tile_answer_button answer, index
    if completion_answer_index_matches index
      content_tag :div , answer, class: 'multiple-choice-answer clicked_right_answer'
    else
      link_to answer, '#', class: "js-multiple-choice-answer multiple-choice-answer nerfed_answer"
    end
  end

  def optional_free_response_text index
    content =""

    if completion_answer_index_matches(index)
      content += content_tag :p, completion_free_response,  class: "free-form-response read"
      content += content_tag :div, "Other", class: 'multiple-choice-answer clicked_right_answer'
    else
      content += content_tag :div, "Other", class: 'multiple-choice-answer nerfed_answer'
    end

    content
  end

  def completion_answer_index_matches(answer_index)
    @completion.answer_index == answer_index
  end

  def completion_free_response
    @completion.free_form_response
  end
end
