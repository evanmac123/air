# -*- coding: utf-8 -*-
require 'acceptance/acceptance_helper'

feature "Sees tiles after completion" do
  context "on activity page" do
    let(:demo) {FactoryBot.create :demo}
    let(:tile) {FactoryBot.create(:tile, status: Tile::ACTIVE, demo: demo)}
    let(:user) {FactoryBot.create :user, demo: demo}
    let(:client_admin) {FactoryBot.create :client_admin, demo: demo}
    context 'sees pop-over under manage link', js: true do
      before do
        visit activity_path(as: client_admin)
      end
      scenario 'show how to return to tile manager only once' do
        expect(page).to have_css('.joyride-tip-guide', visible: true)
        expect(page).to have_content('To return to the tile manager click Manage.')
        visit activity_path(as: client_admin)
        expect(page).not_to have_css('.joyride-tip-guide', visible: true)
      end
      scenario 'clicking Got It button hides the popover' do
        click_link 'Got It'
        expect(page).not_to have_css('.joyride-tip-guide', visible: true)
      end
    end
    context "sees completed tiles" do
      before do
        FactoryBot.create(:tile, status: Tile::ACTIVE, demo: demo)
        FactoryBot.create(:tile_completion, tile: tile, user: user)
        visit activity_path(as: user)
      end
      scenario "shows completed tiles section" do
        expect(page.find('.completed')).to have_content tile.headline
      end
    end
    context "sees active tiles" do
      before do
        @tile = FactoryBot.create(:tile, status: Tile::ACTIVE, demo: demo)
        visit activity_path(as: user)
      end
      scenario "shows active tiles section" do
        expect(page.find('.not-completed')).to have_content @tile.headline
      end
    end
    context "sees tile completion history" do
      before do
        FactoryBot.create(:tile,
          #status: Tile::ACTIVE,
          demo: demo)
        FactoryBot.create(:tile_completion, tile: tile, user: user)
        visit activity_path(as: user)
      end
      scenario "should display tile in history even after it is deactivated" do
        expect(page).to have_css('div#feed_wrapper')
      end
    end
    context "sees two types of tiles" do
      let!(:completed_tile) {FactoryBot.create(:tile, status: Tile::ACTIVE, demo: demo)}
      let!(:active_tile) {FactoryBot.create(:tile, status: Tile::ACTIVE, demo: demo)}
      before do
        FactoryBot.create(:tile_completion, tile: completed_tile, user: user)
        visit activity_path(as: user)
      end
      scenario "should display active tiles before completed tiles" do

        expect(page).to have_css('.completed')
        expect(page).to have_css('.not-completed')
        showing_completed = false
        page.all('div.tile_thumbnail').each do |elem|
          if elem.has_css?('.completed')
            showing_completed = true
          end
          if showing_completed
            expect(elem).not_to have_css('.not-completed')
          end
        end
      end
    end
  end
  context "on tile viewer" do
    let(:demo) {FactoryBot.create :demo}
    let (:tile) {FactoryBot.create(:tile, status: Tile::ACTIVE, demo: demo)}
    let(:user) {FactoryBot.create :user, demo: demo}
    context "sees completed tiles" do
      before do
        FactoryBot.create(:tile, status: Tile::ACTIVE, demo: demo)
        FactoryBot.create(:tile_completion, tile: tile, user: user)
        visit tiles_path(as: user)
      end
      scenario "allows to see tile that was last completed" do
        expect(page).to have_selector('a', 'clicked_right_answer')
      end
    end
    context "sees not-completed tiles" do
      before do
        FactoryBot.create(:tile, status: Tile::ACTIVE, demo: demo)
        visit tiles_path(as: user)
      end
      scenario "allows to see tile that was not completed" do
        expect(page).to have_selector('a', 'multiple-choice-answer.correct')
      end
    end
    context "completes all active tiles" do
      before do
        FactoryBot.create(:multiple_choice_tile, status: Tile::ACTIVE, demo: demo)
        visit tiles_path(as: user)
      end
      scenario "should display message saying 'you’ve completed all of your tiles'", js: true do
        click_link "Eggs"
        expect(page).to have_content("You've finished all new tiles!")
      end
    end
  end

  scenario "moving through completed tiles should let you see multiple done tiles, not just one", js: true do
    board = FactoryBot.create(:demo)
    tiles = FactoryBot.create_list(:multiple_choice_tile, 2, demo: board, status: Tile::ACTIVE)
    user = FactoryBot.create(:user, demo: board)
    tiles.each {|tile| FactoryBot.create(:tile_completion, user: user, tile: tile)}

    visit activity_path(as: user)
    page.all(".tile_thumbnail_image").first.click

    page.find("#next").click
    expect(page).to have_no_content("You've completed all available tiles!")

    page.find("#next").click
    expect(page).to have_no_content("You've completed all available tiles!")
  end
end
