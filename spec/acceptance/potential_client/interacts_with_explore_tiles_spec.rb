require 'acceptance/acceptance_helper'

feature "Interacts with tiles in explore page" do
  def click_first_thumbnail
    page.first('.tile-wrapper').click
  end

  it "by clicking on one and viewing it", js: true do
    FactoryGirl.create(:multiple_choice_tile, :public)
    visit explore_path
    click_first_thumbnail

    should_be_on explore_tile_preview_path(Tile.first)

    expect_supporting_content Tile.first.supporting_content
    expect_question Tile.first.question
    expect_content "99 POINTS"
    expect_answer 0, "Ham"
    expect_answer 1, "Eggs"
    expect_answer 2, "A V8 Buick"
  end

  it "by clicking right or wrong answers and getting special effects"
end
