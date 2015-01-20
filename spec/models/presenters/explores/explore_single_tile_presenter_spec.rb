require 'spec_helper'

describe ExploreSingleTilePresenter do
  it "should filter out duplicate tags" do
    tile_tag = FactoryGirl.create(:tile_tag, title: 'cheezwhiz')
    tile = FactoryGirl.create(:tile, :public, tile_tags: [tile_tag, tile_tag])

    presenter = ExploreSingleTilePresenter.new(tile, tile_tag, false, false)
    presenter.associated_tile_tags.should == [tile_tag]
  end
end
