module BoardSettingsHelpers
  def open_board_settings
    page.find('#board_settings_toggle').click
    wait_for_board_modal
  end

  def wait_for_board_modal
    page.should have_content("Board Settings")
  end

  def board_regular_user_controls_selector
    "#user_board_controls"
  end

  def click_last_delete_link
    within last_row_in_board_settings do
      page.execute_script('$(".delete_board_icon").css("display", "block");') 
      page.find('.delete_board_icon', visible: false).click
    end
  end

  def last_row_in_board_settings
    rows_in_board_settings.last
  end

  def rows_in_board_settings
    within board_regular_user_controls_selector do
      page.all('.board_wrapper')
    end
  end

  def safety_modal_selector
    "#leave_board_safety_modal"
  end

  def wait_for_safety_modal
    page.should have_content("Your account will be permanently deleted")
  end

  def fill_in_safety_text_field(text)
    within(safety_modal_selector) do
      page.find('input[type=text]').set(text)
    end
  end

  def complete_safety_modal
    wait_for_safety_modal
    fill_in_safety_text_field('DELETE')
    within(safety_modal_selector) do
      page.find('input[type=submit]').click
    end
  end
end
