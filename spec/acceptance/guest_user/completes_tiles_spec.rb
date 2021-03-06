require 'acceptance/acceptance_helper'

xfeature 'Completes tiles' do
  let (:board) { FactoryBot.create(:demo, :with_public_slug) }
  let! (:tile_1) { FactoryBot.create(:multiple_choice_tile, status: Tile::ACTIVE, headline: "Tile the first", points: 30, demo: board) }
  let! (:tile_2) { FactoryBot.create(:multiple_choice_tile, status: Tile::ACTIVE, headline: "Tile the second", demo: board) }

  def click_right_answer
    answer(tile_1.correct_answer_index).click
  end

  before do
    visit public_board_path(public_slug: board.public_slug)
    page.find(".close-airbo-modal").click

    click_link tile_1.headline
  end

  scenario 'and can, in the first place, go to the tile page' do
    should_be_on public_tiles_path(board.public_slug)
  end

  xscenario 'and sees the completion in the activity feed', js: true do
    click_right_answer
    visit public_activity_path(board.public_slug)
    within ".feeds" do
      expect_content "completed the tile: \"#{tile_1.headline}\""
    end
  end

  xscenario 'and doesn\'t see the tile in question anymore as completed', js: true do
    click_right_answer
    visit public_activity_path(board.public_slug)
    expect(page.all(".not-completed #tile-thumbnail-#{tile_1.id}")).to be_empty
  end

  xscenario 'and completed tiles count should update', js: true do
    old_number = completed_tiles_number
    click_right_answer
    visit public_activity_path(board.public_slug)
    expect(completed_tiles_number).to eq(0)
  end
end
