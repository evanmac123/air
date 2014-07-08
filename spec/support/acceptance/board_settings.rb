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
end
