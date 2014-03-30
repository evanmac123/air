module BoardSwitchingHelpers
  def expect_current_board_header(board)
    page.should have_content("Current board #{board.name}")
  end

  def open_board_menu
    page.find('#board_switch_toggler').click
  end

  def board_menu_selector
    '.other_boards'  
  end

  def switch_to_board(board_or_board_name)
    board_name = board_or_board_name.kind_of?(Demo) ? board_or_board_name.name : board_or_board_name
    open_board_menu
    within(board_menu_selector) do
      click_link board_name
    end
  end
end
