require 'acceptance/acceptance_helper'

feature 'Views board via public link' do
  scenario 'and can see the tiles' do
    board = FactoryGirl.create(:demo, :with_public_slug)
    tile = FactoryGirl.create(:tile, demo: board)

    visit public_board_path(public_slug: board.public_slug)
    should_be_on activity_path
    expect_content tile.headline
  end

  scenario "but omitting to go through the public link first, gets redirected to signin--i.e. the existence of a public link doesn't mean you can just waltz in without it" do
    visit activity_path
    should_be_on sign_in_path
  end
end
