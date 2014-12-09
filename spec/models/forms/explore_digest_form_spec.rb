require "spec_helper"

describe ExploreDigestForm do
  it "should validate that at least one tile ID was entered" do
    form = ExploreDigestForm.new(tile_ids: [])
    form.should_not be_valid
    form.errors.full_messages.should include("at least one tile ID must be present")
  end

  it "should validate that all tile IDs correspond to a public tile" do
    public_tiles = FactoryGirl.create_list(:tile, 3, :public)
    nonpublic_tiles = FactoryGirl.create_list(:tile, 3)
    tile_ids = [*public_tiles, *nonpublic_tiles].map(&:id)

    form = ExploreDigestForm.new(tile_ids: tile_ids)
    form.should_not be_valid
    form.errors.full_messages.should include("following tiles are not public: #{nonpublic_tiles.map(&:id).sort.join(', ')}")
  end
end
