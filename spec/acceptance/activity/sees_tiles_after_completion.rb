# -*- coding: utf-8 -*-
require 'acceptance/acceptance_helper'

feature "Sees tiles after completion" do
  context "on activity page" do
    let(:demo) {FactoryGirl.create :demo}
    let(:tile) {FactoryGirl.create(:tile, status: Tile::ACTIVE, demo: demo)}
    let(:user) {FactoryGirl.create :user, demo: demo}
    let(:client_admin) {FactoryGirl.create :client_admin, demo: demo}
    context 'sees pop-over under manage link', js: true do
      before do
        visit activity_path(as: client_admin)
      end
      scenario 'show how to return to tile manager only once' do
        page.should have_css('.joyride-tip-guide', visible: true)
        page.should have_content('To return to the tile manager click Manage.')
        visit activity_path(as: client_admin)
        page.should_not have_css('.joyride-tip-guide', visible: true)
      end
      scenario 'clicking Got It button hides the popover' do
        click_link 'Got It'
        page.should_not have_css('.joyride-tip-guide', visible: true)
      end
    end
    context "sees completed tiles" do
      before do
        FactoryGirl.create(:tile, status: Tile::ACTIVE, demo: demo)
        FactoryGirl.create(:tile_completion, tile: tile, user: user)
        visit activity_path(as: user)
      end
      scenario "shows completed tiles section" do
        page.find('.completed').should have_content tile.headline
      end
    end
    context "sees active tiles" do
      before do
        @tile = FactoryGirl.create(:tile, status: Tile::ACTIVE, demo: demo)
        visit activity_path(as: user)
      end
      scenario "shows active tiles section" do
        page.find('.not-completed').should have_content @tile.headline
      end
    end
    context "sees tile completion history" do
      before do
        FactoryGirl.create(:tile,
          #status: Tile::ACTIVE,
          demo: demo)
        FactoryGirl.create(:tile_completion, tile: tile, user: user)
        visit activity_path(as: user)
      end
      scenario "should display tile in history even after it is deactivated" do
        page.should have_css('div#feed_wrapper')
      end
    end
    context "sees two types of tiles" do
      let!(:completed_tile) {FactoryGirl.create(:tile, status: Tile::ACTIVE, demo: demo)}
      let!(:active_tile) {FactoryGirl.create(:tile, status: Tile::ACTIVE, demo: demo)}
      before do
        FactoryGirl.create(:tile_completion, tile: completed_tile, user: user)
        visit activity_path(as: user)
      end
      scenario "should display active tiles before completed tiles" do

        page.should have_css('.completed')
        page.should have_css('.not-completed')
        showing_completed = false
        page.all('div.tile_thumbnail').each do |elem|
          if elem.has_css?('.completed')
            showing_completed = true
          end
          if showing_completed
            elem.should_not have_css('.not-completed')
          end
        end
      end
    end
  end
  context "on tile viewer" do
    let(:demo) {FactoryGirl.create :demo}
    let (:tile) {FactoryGirl.create(:tile, status: Tile::ACTIVE, demo: demo)}
    let(:user) {FactoryGirl.create :user, demo: demo}
    context "sees completed tiles" do
      before do
        FactoryGirl.create(:tile, status: Tile::ACTIVE, demo: demo)
        FactoryGirl.create(:tile_completion, tile: tile, user: user)
        visit tiles_path(as: user)
      end
      scenario "allows to see tile that was last completed" do
        page.should have_selector('a', 'clicked_right_answer')
      end
    end
    context "sees not-completed tiles" do
      before do
        FactoryGirl.create(:tile, status: Tile::ACTIVE, demo: demo)
        visit tiles_path(as: user)
      end
      scenario "allows to see tile that was not completed" do
        page.should have_selector('a', 'right_multiple_choice_answer')
      end
    end
    context "completes all active tiles" do
      before do
        FactoryGirl.create(:multiple_choice_tile, status: Tile::ACTIVE, demo: demo)
        visit tiles_path(as: user)
      end
      scenario "should display message saying 'you’ve completed all of your tiles'", js: true do
        click_link "Eggs"
        page.should have_content("You've finished all new tiles!")
      end
    end
  end

  scenario "moving through completed tiles should let you see multiple done tiles, not just one", js: true do
    board = FactoryGirl.create(:demo)
    tiles = FactoryGirl.create_list(:multiple_choice_tile, 2, demo: board, status: Tile::ACTIVE)
    user = FactoryGirl.create(:user, demo: board)
    tiles.each {|tile| FactoryGirl.create(:tile_completion, user: user, tile: tile)}

    visit activity_path(as: user)
    page.all(".tile_thumbnail_image").first.click

    page.find("#next").click
    page.should have_no_content("You've completed all available tiles!")

    page.find("#next").click
    page.should have_no_content("You've completed all available tiles!")
  end
end
