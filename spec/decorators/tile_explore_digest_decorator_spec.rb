require 'spec_helper'

describe TileExploreDigestDecorator do
  before(:each) do
    @tile = FactoryGirl.create :multiple_choice_tile
  end

  context "#email_site_link" do
    it "should return explore_tile_preview_path" do
      TileExploreDigestDecorator.decorate(@tile).email_site_link.should match "explore/tile_previews"
    end
  end
end