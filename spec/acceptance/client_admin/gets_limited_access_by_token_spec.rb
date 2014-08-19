require 'acceptance/acceptance_helper'

feature 'Client admin gets limited access by token' do
  let(:client_admin) {FactoryGirl.create(:client_admin)}

  scenario "to the explore page, when the token is appended as a query parameter" do
    visit explore_path(explore_token: client_admin.explore_token)

    should_be_on explore_path
  end

  scenario "to the tile tag page, when the token is appended as a query parameter" do
    tile_tag = FactoryGirl.create(:tile_tag)
    visit tile_tag_show_explore_path(tile_tag: tile_tag, explore_token: client_admin.explore_token)

    should_be_on tile_tag_show_explore_path
  end

  scenario "to the random-tile page, when the token is appended as a query parameter" do
    tile = FactoryGirl.create(:multiple_choice_tile, :public)
    visit explore_random_tile_path(explore_token: client_admin.explore_token)
    should_be_on explore_tile_preview_path(tile)
  end

  scenario "when they log in by token in a query parameter, they don't have to keep appending it in subsequent requests" do
    tile_tag = FactoryGirl.create(:tile_tag)

    visit explore_path(explore_token: client_admin.explore_token)
    visit tile_tag_show_explore_path(tile_tag: tile_tag)

    should_be_on tile_tag_show_explore_path
  end

  scenario "can like a tile when logged in by token", js: true do
    tile = FactoryGirl.create(:multiple_choice_tile, :public)

    visit explore_path(explore_token: client_admin.explore_token)

    click_link "Vote Up"
    page.should have_content("Voted Up")
  end

  scenario "can copy a tile when logged in by token", js: true do
    tile = FactoryGirl.create(:multiple_choice_tile, :public, :copyable)
    crank_dj_clear # resize tile images, otherwise copy blows up
    tile.reload

    visit explore_path(explore_token: client_admin.explore_token)

    click_link "Copy"
    page.should have_content("Copied")
  end

  scenario "can't go outside the explore family using a token in the query parameter" do
    visit activity_path(explore_token: client_admin.explore_token)
    should_be_on sign_in_path
  end

  scenario "can't go outside the explore family using a token in the session" do
    visit explore_path(explore_token: client_admin.explore_token)
    visit activity_path(explore_token: client_admin.explore_token)
    should_be_on sign_in_path
  end

  scenario "if they happen to be in another board as a peon, they can still log in via explore token" do
    board = FactoryGirl.create(:demo)
    client_admin.add_board(board)
    client_admin.move_to_new_demo(board)

    client_admin.reload.is_client_admin.should be_false

    visit explore_path(explore_token: client_admin.explore_token)
    should_be_on explore_path
  end

  scenario "the board switcher is nerfed and pops a login modal instead", js: true do
    visit explore_path(explore_token: client_admin.explore_token)
    page.find('#board_switch_toggler').click

    page.all('.other_boards', visible: true).should be_empty
    pending "and there's a login modal"
  end
end
