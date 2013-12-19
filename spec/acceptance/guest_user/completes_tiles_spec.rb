require 'acceptance/acceptance_helper'

feature 'Completes tiles' do
  let (:board) { FactoryGirl.create(:demo, :with_public_slug) }
  let! (:tile_1) { FactoryGirl.create(:multiple_choice_tile, status: Tile::ACTIVE, headline: "Tile the first", points: 30, demo: board) }
  let! (:tile_2) { FactoryGirl.create(:multiple_choice_tile, status: Tile::ACTIVE, headline: "Tile the second", demo: board) }

  def click_right_answer
    answer(tile_1.correct_answer_index).click
  end

  before do
    visit public_board_path(public_slug: board.public_slug)
    close_tutorial_lightbox
    click_link tile_1.headline
  end

  scenario 'and can, in the first place, go to the tile page' do
    should_be_on public_tiles_path(board.public_slug)
  end

  scenario 'and sees the happy flash', js: true do
    click_right_answer
    expect_right_answer_reaction
  end

  scenario 'and sees the completion in the activity feed', js: true do
    click_right_answer
    visit activity_path
    expect_content "completed the tile: \"#{tile_1.headline}\""
  end

  scenario 'and doesn\'t see the tile in question anymore', js: true do
    click_right_answer
    visit activity_path
    page.all("#tile-thumbnail-#{tile_1.id}").should be_empty
  end

  scenario 'and the score should update', js: true do
    click_right_answer
    visit activity_path
    expect_content "POINTS TO NEXT TICKET 10/20 POINTS"
  end
end
