class PreviewInteraction < TileInteraction

  def standard_answer_group
    buttons, index = default_answer_buttons
    buttons += optional_free_response_text(index) if tile.allow_free_response?
    buttons
  end

  def free_response_answer_group
    free_response_edit_fragment
  end

  def custom_form_answer_group
    content = custom_form_edit_fragment
    buttons, _IGNORE_INDEX_ = default_answer_buttons
    content += buttons
  end

  def tile_answer_button answer, answer_index
    if is_possible_correct_answer?(answer_index)
      link_to answer, "#", class: "js-multiple-choice-answer multiple-choice-answer correct  #{action_answer_class(answer_index)}",
        data: {tile_id: tile.id, answer_index: answer_index}
    else
      link_to answer, '#', class: "js-multiple-choice-answer multiple-choice-answer incorrect "
    end
  end

  def optional_free_response_text index
    content =""
    content += free_response_edit_fragment true
    content += link_to "Other", "#", class: "js-free-text-show multiple-choice-answer correct "
    content
  end


  # Builds the custom form portion ofthe interaction
  # NOTE by convention the first button in the interaction is the button that triggers the form
  #
  # NOTE This implementation only supports a hard-coded custom_form[phone] text field
  # however a future implementation (with some enhancements to the tile builder)
  # might allow for arbitrary number of fields and input types (checkbox,
  # radios, etc.)
  def custom_form_edit_fragment
    answer_index = 0
    content = ""

    content += content_tag :div,   class: "free-text-panel js-custom-form-panel optional" do
      s = content_tag(:i, "",  class: "js-custom-form-hide free-text-hide fa fa-remove fa-1x")
      s += phone_number_form
      s += link_to "Submit", "#", class: "js-multiple-choice-answer multiple-choice-answer js-custom-form correct", data: {tile_id: tile.id, answer_index: answer_index }
      s += content_tag :div, "Answer can't be empty", class: "answer_target",  style: "display: none"
      s
    end
    content
  end

  def phone_number_form
    text_field_tag "custom_form[phone]", nil, id: "custom_form_phone", maxlength: 10, placeholder: "Phone Number", class:""
  end

  def arbitrary_form
    #NOTE not implemented
  end

  def free_response_edit_fragment optional=false
    content = ""

    if optional
      cust_css = "optional"
      answer_index = tile.multiple_choice_answers.length #Always the last answer_index
    else
      cust_css =  ""
      answer_index = 0
    end

    content += content_tag :div,   class: "js-free-text-panel free-text-panel #{cust_css}" do
      s = optional ? content_tag(:i, "",  class: "js-free-text-hide free-text-hide fa fa-remove fa-1x") : "".html_safe
      s += text_area_tag "free_form_response", nil, maxlength: 400, placeholder: "Enter your response here", class:"js-free-form-response free-form-response edit"
      s += link_to "Submit", "#", class: "js-multiple-choice-answer js-free-text multiple-choice-answer correct ", data: {tile_id: tile.id, answer_index: answer_index }
      s += content_tag :div, "Response cannot be empty", class: "answer_target",  style: "display: none"
      s
    end
    content
  end


  def button_for_type_and_index (answer_index, type)
    answer_index == tile.correct_answer_index && tile.question_subtype == type
  end

  def action_answer_class(answer_index)
    css_class =''
    if user.is_a?(User)
      if button_for_type_and_index(answer_index, Tile::INVITE_SPOUSE)
        css_class =  'invitation_answer'
      elsif button_for_type_and_index(answer_index,  Tile::CHANGE_EMAIL)
        css_class =  'change_email_answer'
      elsif button_for_type_and_index(answer_index, "custom_form")
        css_class =  'js-custom-form-show custom'
      end
    end
    css_class
  end

  def is_possible_correct_answer?(answer_index)
    answer_index == tile.correct_answer_index || tile.is_survey? || tile.is_action?
  end
end
