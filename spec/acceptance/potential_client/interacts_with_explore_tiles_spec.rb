require 'acceptance/acceptance_helper'

feature "Interacts with tiles in explore page" do
  def click_first_thumbnail
    page.first('.tile-wrapper').click
  end

  it "by clicking on one and viewing it", js: true do
    FactoryGirl.create(:tile, :public)
    visit explore_path
    click_first_thumbnail

    should_be_on explore_tile_preview_path(Tile.first)

    pending "sees stuff like in the tile viewer hoojamajiggy"
  end

  it "by clicking right or wrong answers and getting special effects"
end
