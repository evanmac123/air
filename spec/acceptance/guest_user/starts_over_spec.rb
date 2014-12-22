require 'acceptance/acceptance_helper'

feature 'Starts over' do
  let (:board) { FactoryGirl.create(:demo, :with_public_slug) }
  let!(:tile)  { FactoryGirl.create(:multiple_choice_tile, :active, demo_id: board.id) }

  def start_over_button_selector
    "a#guest_user_start_over_button"
  end

  def expect_start_over_button
    page.find(start_over_button_selector, visible: true)
  end

  def expect_no_start_over_button
    page.all(start_over_button_selector, visible: true).should be_empty
  end

  def click_start_over_button
    page.find(start_over_button_selector, visible: true).click
  end

  context "before finishing any tiles" do
    it "should not show a start over button" do
      visit public_board_path(board.public_slug)
      expect_no_start_over_button
    end
  end

  context "after finishing at least one tile" do
    before do
      visit public_board_path(board.public_slug)
      close_tutorial_lightbox
      click_link tile.headline
      #answer(tile.correct_answer_index).click
      page.find('.right_multiple_choice_answer').click

      close_conversion_form
    end

    it "should show a start over button", js: true do
      expect_start_over_button
    end

    it "should reset guest user's progress when they click it", js: true do
      click_start_over_button

      should_be_on public_activity_path(board.public_slug)
      guest_user = GuestUser.last
      guest_user.tile_completions.should be_empty
      guest_user.acts.should be_empty
      guest_user.points.should be_zero
      guest_user.tickets.should be_zero
    end

    it "should not appear after being clicked", js: true do
      click_start_over_button
      expect_no_start_over_button

      visit public_board_path(board.public_slug)
      expect_no_start_over_button

      click_link tile.headline
      expect_no_start_over_button
    end
  end

  context "conversion form pops as normal after starting over" do
    context "in a many-tile board" do
      before do
        @tiles = [
          tile, 
          FactoryGirl.create(:multiple_choice_tile, :active, headline: "Tile 2", demo_id: board.id),
          FactoryGirl.create(:multiple_choice_tile, :active, headline: "Tile 3", demo_id: board.id)
        ]
      end

      it "should pop after doing two tiles", js: true do
        visit public_board_path(board.public_slug)
        close_tutorial_lightbox

        click_link tile.headline
        @tiles[0,2].each do |tile|
          page.find('.right_multiple_choice_answer:not(.clicked_right_answer)').click
          #answer(tile.correct_answer_index).click
        end
        close_conversion_form

        click_start_over_button
        close_tutorial_lightbox

        click_link tile.headline
        @tiles[0,2].each do |tile|
          page.find('.right_multiple_choice_answer:not(.clicked_right_answer)').click
          #answer(tile.correct_answer_index).click
        end
        expect_conversion_form
      end
    end
  end
end
