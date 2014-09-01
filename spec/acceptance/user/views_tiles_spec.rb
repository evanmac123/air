require 'acceptance/acceptance_helper'

feature 'User views tile' do
  def no_tiles_message
    "There aren't any tiles available at this time. Check back later for more."
  end

  def click_next_button
    page.find('#next').click
  end

  def click_prev_button
    page.find('#prev').click
  end

  context "when there are tiles to be seen" do
    before(:each) do
      @demo = FactoryGirl.create(:demo)
      @kendra = FactoryGirl.create(:user, demo: @demo, password: 'milking', session_count: 5)

      ['make toast', 'discover fire'].each do |tile_headline|
        FactoryGirl.create(:tile, headline: tile_headline, demo: @demo)
      end

      @make_toast = Tile.find_by_headline('make toast')
      @discover_fire = Tile.find_by_headline('discover fire')
      @make_toast.update_attributes(activated_at: Time.now - 60.minutes)
      @discover_fire.update_attributes(activated_at: Time.now)

      bypass_modal_overlays(@kendra)
      signin_as(@kendra, 'milking')
    end

    scenario 'views tile image', js: true do
      # Click on the first tile, and it should take you to the tiles  path
      click_link 'discover fire'
      should_be_on tiles_path

      expect_current_tile_id(@discover_fire)
      click_next_button
      expect_current_tile_id(@make_toast)
    end

    context "when a tile has no attached link address" do
      before(:each) do
        @make_toast.link_address.should be_blank
      end

      scenario "it should not be wrapped in a link" do
        visit tile_path(@make_toast)
        toast_image = page.find("img[alt='make toast']")
        parent = page.find(:xpath, toast_image.path + "/..")

        parent.tag_name.should_not == "a"
        parent.click
        should_be_on tiles_path
      end
    end

    it "should not show the no-content message" do
      expect_no_content no_tiles_message
    end

    it "should ping", js: true do
      FakeMixpanelTracker.clear_tracked_events
      visit tiles_path

      crank_dj_clear
      FakeMixpanelTracker.events_matching('Tile - Viewed').should have(1).ping
      FakeMixpanelTracker.events_matching('Tile - Viewed', tile_id: @discover_fire.id).should have(1).ping

      click_next_button
      crank_dj_clear
      FakeMixpanelTracker.events_matching('Tile - Viewed').should have(2).pings
      FakeMixpanelTracker.events_matching('Tile - Viewed', tile_id: @make_toast.id).should have(1).ping

      click_next_button
      crank_dj_clear
      FakeMixpanelTracker.events_matching('Tile - Viewed').should have(3).pings
      FakeMixpanelTracker.events_matching('Tile - Viewed', tile_id: @discover_fire.id).should have(2).pings

      click_prev_button
      crank_dj_clear
      FakeMixpanelTracker.events_matching('Tile - Viewed').should have(4).pings
      FakeMixpanelTracker.events_matching('Tile - Viewed', tile_id: @make_toast.id).should have(2).pings

      click_prev_button
      crank_dj_clear
      FakeMixpanelTracker.events_matching('Tile - Viewed').should have(5).pings
      FakeMixpanelTracker.events_matching('Tile - Viewed', tile_id: @discover_fire.id).should have(3).pings
    end
  end

  context "when there are no tiles to be seen" do
    it "should have a helpful message" do
      user = FactoryGirl.create(:user, :claimed)
      user.demo.tiles.should be_empty

      visit activity_path(as: user)
      expect_content no_tiles_message
    end
  end
end
