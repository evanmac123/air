require 'acceptance/acceptance_helper'

feature 'Previews a public tile' do
  before do
    @tile = FactoryGirl.create(:tile, :public)
    @tile_tag = FactoryGirl.create(:tile_tag)
    @tile.tile_tags << @tile_tag

    visit explore_tile_preview_path(@tile.id, as: a_client_admin)
  end

  context "when the user clicks through a tag in the preview page navbar" do
    before do
      within '.tile_preview_navbar' do
        click_link @tile_tag.title
      end
    end

    it "pings when the user clicks through the tag" do
      FakeMixpanelTracker.clear_tracked_events
      crank_dj_clear

      FakeMixpanelTracker.should have_event_matching('Explore Tile Preview Page', action: 'Clicked Tile Tag', tag: @tile_tag.title)
    end

    it "takes us to where we would want" do
      should_be_on tile_tag_show_explore_path
      page.find('.tile_tag h1').should have_content @tile_tag.title
    end
  end
end
