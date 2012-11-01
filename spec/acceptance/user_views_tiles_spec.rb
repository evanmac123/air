require 'acceptance/acceptance_helper'

feature 'User views tile' do
  before(:each) do
    User.any_instance.stubs(:create_tutorial_if_none_yet)

    Demo.find_each {|f| f.destroy }
    @demo = FactoryGirl.create(:demo)
    @kendra = FactoryGirl.create(:user, demo_id: @demo.id, password: 'milking')
    ['make toast', 'discover fire'].each do |tile_headline|
      FactoryGirl.create(:tile, headline: tile_headline, demo: @demo)
    end

    @make_toast = Tile.find_by_headline('make toast')
    @discover_fire = Tile.find_by_headline('discover fire')
    signin_as_admin

    signin_as(@kendra, 'milking')
    visit activity_path
    Delayed::Job.delete_all
  end

  scenario 'views tile image', js: :webkit do
    # Click on the first tile, and it should take you to the tiles  path
    first_tile_link = "/tiles?start=#{@make_toast.id}"
    page.find("a[href='#{first_tile_link}'] #tile-thumbnail-#{@make_toast.id}").click
    current_path.should == tiles_path
    expect_content "Tile: 1 of 2"
    expect_content "MY PROFILE"

    # Verify mixpanel ping for 'viewed tile', "via" => "thumbnail"
    data = {"via" => "thumbnail", "tile_id" => @make_toast.id.to_s}.merge(@kendra.data_for_mixpanel)
    crank_dj_clear
    FakeMixpanelTracker.tracked_events.count.should == 1
    FakeMixpanelTracker.events_matching("viewed tile", data).should be_present
    FakeMixpanelTracker.clear_tracked_events
    page.find("img##{@make_toast.id}").should be_visible
    page.find("img##{@discover_fire.id}").should_not be_visible

    # Click the "next" button
    page.find("#next").click
    wait_until { page.find("img##{@discover_fire.id}").visible? }
    wait_until { not page.find("img##{@make_toast.id}").visible? }
    expect_content "Tile: 2 of 2"

    # Verify mixpanel ping for 'viewed tile', "via" => "next_button"
    data["via"] = "next_button"
    crank_dj_clear
    FakeMixpanelTracker.tracked_events.count.should == 1
    FakeMixpanelTracker.events_matching("viewed tile", data).should be_present
  end
end
