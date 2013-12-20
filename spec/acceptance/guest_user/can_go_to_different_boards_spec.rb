require 'acceptance/acceptance_helper'

feature 'can go to different boards' do
  let (:board_1) { FactoryGirl.create(:demo, :with_public_slug) }
  let (:board_2) { FactoryGirl.create(:demo, :with_public_slug) }
  let! (:tile_1)  { FactoryGirl.create(:multiple_choice_tile, demo: board_1, headline: "You are in board 1", status: Tile::ACTIVE) }
  let! (:tile_2)  { FactoryGirl.create(:multiple_choice_tile, demo: board_2, headline: "You are in board 2", status: Tile::ACTIVE) }

  it "should leave them in the last board they visited" do
    visit public_board_path(board_1.public_slug)
    expect_content tile_1.headline
    expect_no_content tile_2.headline

    visit public_board_path(board_2.public_slug)
    expect_no_content tile_1.headline
    expect_content tile_2.headline
  end
end
