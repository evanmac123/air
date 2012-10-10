require 'acceptance/acceptance_helper'

feature 'User views tile' do
  before(:each) do
    Demo.find_each {|f| f.destroy }
    @demo = FactoryGirl.create(:demo)
    @kendra = FactoryGirl.create(:user, demo_id: @demo.id, password: 'milking')
    ['make toast', 'discover fire'].each do |tile_name|
      FactoryGirl.create(:tile, name: tile_name, demo: @demo)
    end

    @make_toast = Tile.find_by_name('make toast')
    @discover_fire = Tile.find_by_name('discover fire')
    signin_as_admin

    # Add thumbnail and image to @make_toast
    visit edit_admin_demo_tile_path(@demo, @make_toast)
    attach_file "tile[image]", tile_fixture_path('cov1.jpg')
    attach_file "tile[thumbnail]", tile_fixture_path('cov1_thumbnail.jpg')
    click_button 'Update Tile'
    
    # Add thumbnail and image to @discover_fire
    visit edit_admin_demo_tile_path(@demo, @discover_fire)
    attach_file "tile[image]", tile_fixture_path('cov2.jpg')
    attach_file "tile[thumbnail]", tile_fixture_path('cov2_thumbnail.jpg')
    click_button 'Update Tile'

    expect_content 'cov1.jpg'
    expect_content 'cov1_thumbnail.jpg'
    expect_content 'cov2.jpg'
    expect_content 'cov2_thumbnail.jpg'
    signin_as(@kendra, 'milking')
    visit activity_path
    Delayed::Job.delete_all
  end

  scenario 'views tile image', js: true do
    # find the image with the thumbnail for attach_file "tile[image]", tile_fixture_path('cov1.jpg')
    page.find("#tile-thumbnail-#{@make_toast.id}").click
    expect_content "Tile: 1 of 2"

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
