module TilesHelper
  def tile_class(tile)
    (@show_completed_tiles == true) || current_user.tile_completions.where(tile_id: tile.id).exists? ? 'completed' : 'not_completed'
  end

  # nil is definitely not a url
  # with dots
  # without spaces
  # have at least one letter
  # no two dots together
  # starts with letter, ends with not dot
  def is_url? str
    !str.nil? && \
    str.include?(".") && \
    !str.include?(" ") && \
    str[/[a-zA-Z]+/] && \
    !str[/\.{2,}/] && \
    str[/^[\w].*[^.]$/]
  end

  def make_full_url str
    if is_url? str
      (str.start_with?("http://", "https://") ? "" : "http://") + str
    else
      str
    end
  end

  def all_tiles_done_link
    if request.cookies["user_onboarding"].present? && !current_user.user_onboarding.completed
      onboarding_activity_path(current_user.user_onboarding.id)
    elsif params[:public_slug] || current_user.is_a?(GuestUser)
      slug = params[:public_slug] || current_user.demo.public_slug
      public_activity_path(slug)
    else
      activity_path(board_id: current_user.demo_id)
    end
  end

  def all_tiles_done_link_text
    if request.cookies["user_onboarding"].present? && !current_user.user_onboarding.completed
      "See Activity Dashboard"
    else
      "Return to homepage"
    end
  end

  def tile_completed?(tile, execute_query = true)
    if execute_query
      @tile_completions ||= current_user.tile_completions.pluck(:tile_id)
      @tile_completions.include?(tile.id)
    end
  end

  def display_tile_for_search(tile)
    if do_not_display_unanswered_archived_tiles(tile)
      return false
    else
      return true
    end
  end

  def do_not_display_unanswered_archived_tiles(tile)
    current_user.end_user? && tile.archived? && !tile_completed?(tile)
  end


  def tile_answer_button tile, answer, answer_index
    if tile.non_preview_of_completed_tile?
      button_in_live_mode tile, answer, answer_index
    else 
      button_in_preview_mode tile, answer, answer_index
    end
  end

  def button_in_live_mode tile, answer, answer_index
    if tile.user_completed_tile_with_answer_index(answer_index) 
      content_tag :div , answer, class: 'multiple-choice-answer clicked_right_answer' 
    else 
      link_to answer, '#', class: "js-multiple-choice-answer multiple-choice-answer nerfed_answer" 
    end 
  end

  def button_in_preview_mode tile, answer, answer_index
    if tile.is_possible_correct_answer?(answer_index) 
      link_to answer, "#", class: "js-multiple-choice-answer multiple-choice-answer correct  #{tile.action_answer_class(answer_index)}", 
        data: {tile_id: tile.id, answer_index: answer_index} 
    else 
      link_to answer, '#', class: "js-multiple-choice-answer multiple-choice-answer incorrect " 
    end 
  end

  def build_tile_interaction tile
    if tile.question_subtype == "free_response"
      free_response_answer_group tile
    else
      standard_answer_group tile
    end
  end

  def free_response_answer_group tile
    content =""
    if tile.non_preview_of_completed_tile?
      content += content_tag :p, tile.free_form_response,  class: "free-form-response read"
      content += content_tag :div, "Submit my answer", class: 'multiple-choice-answer clicked_right_answer' 
    else
      content = free_response_fragment tile, false
    end
    content.html_safe
  end



  def standard_answer_group tile
    buttons ="" 
    index = nil
    tile.multiple_choice_answers.each_with_index do |answer, answer_index|
      buttons += content_tag :div, class: "js-tile-answer-container" do
        index = answer_index + 1
        btn = tile_answer_button tile, answer, answer_index
        btn += content_tag(:div, "",  class: "answer_target", style: "display: none")
        btn
      end
    end

    buttons += optional_free_response_text(tile, index) if tile.allow_free_response?
    buttons.html_safe
  end

  def optional_free_response_text tile, index
    content =""

    if tile.non_preview_of_completed_tile?
      if tile.user_completed_tile_with_answer_index(index) 
        content += content_tag :p, tile.free_form_response,  class: "free-form-response read"
        content += content_tag :div, "Other", class: 'multiple-choice-answer clicked_right_answer' 
      else
        content += content_tag :div, "Other", class: 'multiple-choice-answer nerfed_answer' 
      end
    else
      content += free_response_edit_fragment tile, true
      content += link_to "Other", "#", class: "js-free-text-show multiple-choice-answer correct "
    end

    content.html_safe
  end

  def free_response_edit_fragment tile, optional=false
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
      s += link_to "Submit My Answer", "#", class: "js-multiple-choice-answer free-text multiple-choice-answer correct ", data: {tile_id: tile.id, answer_index: answer_index }
      s += content_tag :div, "Response cannot be empty", class: "answer_target",  style: "display: none"
      s
    end
    content.html_safe
  end

end
