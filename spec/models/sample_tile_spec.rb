require 'spec_helper'

describe SampleTile do
  it "should satisfy the rule only after both rules are satisfied" do
    @tile = SampleTile.new
    @tile.position.should == 0
    @tile.headline.should == "Sample Tile"
    @tile.image.url.should == "https://hengage-assets-staging.s3.amazonaws.com/assets/tutorial/sample_tile_image.png"
    @tile.image.image_size.should == "620x620"

    @tile.thumbnail.should == "https://hengage-assets-staging.s3.amazonaws.com/assets/tutorial/sample_tile_thumbnail.png"

    @tile.thumbnail(:hover).should == "https://hengage-assets-staging.s3.amazonaws.com/assets/tutorial/sample_tile_hover_thumbnail.png"
  end
end
