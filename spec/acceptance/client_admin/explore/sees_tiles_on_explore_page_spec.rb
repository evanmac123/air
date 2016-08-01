require 'acceptance/acceptance_helper'

feature 'Sees tiles on explore page' do
  it "should show only tiles that are public and active or archived" do
    FactoryGirl.create_list(:tile, 2, :public)
    FactoryGirl.create(:tile, headline: "I do not appear in public")
    FactoryGirl.create(:tile, :public, status: Tile::ARCHIVE)

    visit explore_path(as: a_client_admin)
    expect_thumbnail_count 3
    page.should_not have_content "I do not appear in public"
  end

  it "should have a working \"Show More\" button", js: true do
   #FIXME should not have sleeps in tests

    FactoryGirl.create_list(:tile, 47, :public)
    visit explore_path(as: a_client_admin)
    expect_thumbnail_count 16

    # These "sleep"s are a terrible hack, but I haven't gotten any of the
    # saner ways to get Poltergeist to wait for the AJAX request to work yet.
    show_more_tiles_link.click
    #sleep 5
    expect_thumbnail_count 32

    show_more_tiles_link.click
    #sleep 5
    expect_thumbnail_count 47
  end

  it "should ping when the more-tiles button is clicked", js: true do
    pending "Convert to controller spec"
    FactoryGirl.create_list(:tile, 20, :public)
    visit explore_path(as: a_client_admin)

    crank_dj_clear
    FakeMixpanelTracker.clear_tracked_events

    show_more_tiles_link.click
    sleep 5
    crank_dj_clear
    FakeMixpanelTracker.should have_event_matching('Explore Topic Page', action: 'Clicked See More')
  end


  context "when clicking through a tile" do
    before do
      @tile = FactoryGirl.create(:tile, :public)
    end
    it "pings" do
    pending "Convert to controller spec"
      visit explore_path(as: a_client_admin)
      page.first('a.tile_thumb_link').click

      FakeMixpanelTracker.clear_tracked_events
      crank_dj_clear
      FakeMixpanelTracker.should have_event_matching('Explore Main Page', {action: "Tile Thumbnail Clicked"})
    end

    it "pings when clicking through a tile in a later batch", js: true do#, driver: :selenium do
    pending "Convert to controller spec"
      FactoryGirl.create_list(:tile, 38, :public)
      visit explore_path(as: a_client_admin)

      2.times { click_link 'More' }

      page.all('a.tile_thumb_link')[38].click

      FakeMixpanelTracker.clear_tracked_events
      crank_dj_clear
      FakeMixpanelTracker.should have_event_matching('Explore Main Page', {action: "Tile Thumbnail Clicked"})
    end
  end

  context "when clicking the \"Explore\" link to go back to the main explore page from a topic page" do
    it "should ping" do
    pending "Convert to controller spec"
      tile_tag = FactoryGirl.create(:tile_tag)
      visit tile_tag_show_explore_path(tile_tag: tile_tag.id, as: a_client_admin)

      within('.explore_section') { click_link "Explore" }

      FakeMixpanelTracker.clear_tracked_events
      crank_dj_clear

      FakeMixpanelTracker.should have_event_matching('Explore Topic Page', action: 'Back To Explore')
    end
  end
end
