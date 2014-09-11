require 'spec_helper'

describe TileExploreDigestDecorator do
  before(:each) do
    @tile = FactoryGirl.create :multiple_choice_tile
    @user = FactoryGirl.build_stubbed(:user)
    @user.stubs(:explore_token).returns("fake_token")
  end

  context "#email_site_link" do
    it "should return explore_tile_preview_path" do
      TileExploreDigestDecorator.decorate(@tile, context: {user: @user}).email_site_link.should match "explore/tile"
    end
  end
end
