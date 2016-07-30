require 'acceptance/acceptance_helper'

feature 'Previews a public tile' do
  before do
    @tile = FactoryGirl.create(:tile, :public)
    @first_tag = @tile.tile_tags.first
    @first_tag.should be_present
    visit explore_tile_preview_path(@tile.id, as: a_client_admin)
  end

  context "when the user clicks through a tag in the preview page navbar" do
    before do
      click_link @first_tag.title
    end

    it "pings when the user clicks through the tag" do
      pending 'Convert to controller spec'
      FakeMixpanelTracker.clear_tracked_events
      crank_dj_clear

      FakeMixpanelTracker.should have_event_matching('Explore Tile Preview Page', action: 'Clicked Tile Tag', tag: @first_tag.title)
    end

    it "takes us to where we would want" do
      should_be_on tile_tag_show_explore_path
      page.should have_content "Explore: #{@first_tag.topic.name}: #{@first_tag.title}"
    end
  end
end
