require 'acceptance/acceptance_helper'

feature 'Board Welcome Modal for users' do

  let (:board) { FactoryBot.create(:demo, :with_public_slug) }
  let (:user) { FactoryBot.create(:user, demo: board) }

  context 'When a user in a board with active tiles', js: true do
    before do
      FactoryBot.create(:tile, status: Tile::ACTIVE, demo: board)
      visit activity_path(as: user)
    end

    it 'should show the welcome modal to a new user' do
      within ".js-board-welcome-modal" do
        expect(page).to have_content(board.intro_message)
      end
    end

    it "should not show the welcome message on subsequent page views" do
      visit activity_path
      expect(page).to_not have_content(board.welcome_message)
    end
  end
end
