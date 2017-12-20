require 'spec_helper'

describe TileExploreDigestDecorator do
  before(:each) do
    @tile = FactoryBot.create :multiple_choice_tile
    @user = FactoryBot.build_stubbed(:user)
    @user.stubs(:explore_token).returns("fake_token")
  end

  context "#email_site_link" do
    it "should return explore_tile_preview_path" do
      expect(TileExploreDigestDecorator.decorate(@tile, context: {user: @user}).email_site_link).to match "explore/tile"
    end
  end
end
