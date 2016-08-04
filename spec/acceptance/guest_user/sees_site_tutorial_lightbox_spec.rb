require 'acceptance/acceptance_helper'

feature 'Lightbox for guest users' do
  def guest_user_specific_content
    "Already a user? Sign in."
  end

  let (:board) {FactoryGirl.create(:demo, :with_public_slug)}

  context 'When a guest in a board with active tiles', js: true do
    before do
      FactoryGirl.create(:tile, status: Tile::ACTIVE, demo: board)
      visit public_board_path(board.public_slug)
    end

    it 'should show the tutorial lightbox to a guest user', js: true do
      within(site_tutorial_lightbox_selector, visible: true) { expect_content site_tutorial_content }
    end

    it "should include some special guest-user specific instructions", js: true do
      within(site_tutorial_lightbox_selector, visible: true) { expect_content guest_user_specific_content }
      click_link "Sign in"
      should_be_on new_session_path
    end
  end

  context 'When a guest in a board without active tiles', js: true do
    it 'should not show the tutorial lightbox to a guest user' do
      visit public_board_path(board.public_slug)
      expect_no_site_tutorial_lightbox
    end
  end
end
