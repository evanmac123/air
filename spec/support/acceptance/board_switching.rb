module BoardSwitchingHelpers
  # This is a little hack because including ActionView::Helpers::TextHelper
  # directly in this module breaks unrelated tests, possibly for a good reason,
  # definitely for a reason I have little to no interest in tracking down. So
  # we wrap it up in this class instead.
  class TextHelpifier
    include ActionView::Helpers::TextHelper
  end


  def expect_current_board_header(board_or_board_name)
    board_name = board_or_board_name.kind_of?(Demo) ? board_or_board_name.name : board_or_board_name
    truncated_name = TextHelpifier.new.truncate(board_name, length: 15)
    # regex because in one some places it's CURRENT BOARD
    page.should have_content(/Current board #{truncated_name}/i)
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
