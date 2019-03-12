require 'acceptance/acceptance_helper'

xfeature 'Board Welcome Modal for guest users' do
  def guest_user_specific_content
    "Already a user? Sign in."
  end

  let (:board) { FactoryBot.create(:demo, :with_public_slug) }

  context 'When a guest in a board with active tiles', js: true do
    before do
      FactoryBot.create(:tile, status: Tile::ACTIVE, demo: board)
      visit public_board_path(board.public_slug)
    end

    it 'should show the welcome modal to a guest user' do
      within ".js-board-welcome-modal" do
        expect(page).to have_content(board.intro_message)
      end
    end

    it "should have an option for the guest user to sign in" do
      within ".js-board-welcome-modal" do
        expect(page).to have_css(".already-a-user-text")
      end
    end

    it "should not show the welcome message on subsequent page views" do
      visit public_board_path(board.public_slug)
      expect(page).to_not have_content(board.welcome_message)
    end
  end
end
