require 'spec_helper'

describe ExploreSingleAdminTilePresenter do
  it "should filter out duplicate tags" do
    tile_tag = FactoryGirl.create(:tile_tag, title: 'cheezwhiz')
    tile = FactoryGirl.create(:tile, :public, tile_tags: [tile_tag, tile_tag])

    presenter = ExploreSingleAdminTilePresenter.new(tile, tile_tag, false, false)
    presenter.associated_tile_tags.should == [tile_tag]
  end

  context "the cache key" do
    let(:tile) {FactoryGirl.create(:tile)}

    context "when the tile_tag argument is nil" do
      it "should serialize it properly" do
        presenter = ExploreSingleAdminTilePresenter.new(tile, nil, false, false)
        presenter.cache_key.should_not include("TileTag")
        # Two dashes separated by nil.to_s, that is, an empty string
        presenter.cache_key.should include("--")
      end
    end

    context "when the tile_tag argument is a TileTag" do
      it "should serialize it using the database ID rather than the in-memory object ID" do
        tag = FactoryGirl.create(:tile_tag)

        presenter = ExploreSingleAdminTilePresenter.new(tile, tag, false, false)
        presenter.cache_key.should_not include("TileTag")
        presenter.cache_key.should include("-#{tag.id.to_s}-")
      end
    end
  end
end
