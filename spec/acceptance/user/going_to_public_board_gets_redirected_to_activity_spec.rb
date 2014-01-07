require 'acceptance/acceptance_helper'

feature 'Signed-in user going to a public board' do
  it 'gets redirected to the ordinary activity page' do
    board = FactoryGirl.create(:demo, :with_public_slug)
    user = FactoryGirl.create(:user, :claimed)
    visit activity_path(as: user) # even by the back door, this sets the cookie

    visit public_board_path(board.public_slug)
    should_be_on activity_path
  end
end
