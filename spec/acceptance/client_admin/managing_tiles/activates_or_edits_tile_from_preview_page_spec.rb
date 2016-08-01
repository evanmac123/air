#FIXME these tests are passing but pretty poorly written. We don't need so many
#test case here.!
#
require 'acceptance/acceptance_helper'

feature 'Activates or edits tile from preview page', js:true do

  context "an active tile" do
    before do
      @tile = FactoryGirl.create(:multiple_choice_tile, status: Tile::ACTIVE)
      @client_admin = FactoryGirl.create(:client_admin, demo: @tile.demo)
      visit client_admin_tiles_path(as: @client_admin)
      within "#active_tiles" do
        page.find("#single-tile-#{@tile.id} .tile-wrapper a.tile_thumb_link").click
      end

      page.find("#stat_toggle").click
    end

    it "should allow the tile to be deactivated"  do
      within status_change_sub do
        click_deactivate_link
      end
      expect_tile_to_section_change "#active_tiles", "#archived_tiles"
    end

    it "should link to the edit page" do
      pending 'Convert to controller spec'
      click_edit_link
      expect_mixpanel_action_ping('Tile Preview Page - Posted', 'Clicked Edit button')
    end

    it "should ping on clicking back to tiles button" do
      pending 'Convert to controller spec'
      click_link "Back to Tiles"
      expect_mixpanel_action_ping('Tile Preview Page - Posted', 'Clicked Back to Tiles button')
    end

    it "should ping on clicking new tile button" do
      pending 'Convert to controller spec'
      click_link "New Tile"
      expect_mixpanel_action_ping('Tile Preview Page - Posted', 'Clicked New Tile button')
    end

    it "should ping on clicking archive button" do
      pending 'Convert to controller spec'
      click_link "Archive"
      expect_mixpanel_action_ping('Tile Preview Page - Posted', 'Clicked Archive button')
    end

    it "should not show an activate link" do
      expect_no_activate_link
    end
  end

  context "an inactive tile" do
    before do
      @tile = FactoryGirl.create(:multiple_choice_tile, status: Tile::ARCHIVE, activated_at: Time.now)
      @client_admin = FactoryGirl.create(:client_admin, demo: @tile.demo)
      visit client_admin_tiles_path(as: @client_admin)
      within "#archived_tiles" do
        page.find("#single-tile-#{@tile.id} .tile-wrapper a.tile_thumb_link").click
      end
      page.find("#stat_toggle").click
    end

    it "should allow the tile to be activated" do
      within status_change_sub do
        click_reactivate_link
      end
      expect_tile_to_section_change "#archived_tiles", "#active_tiles"
    end

    it "should link to the edit page" do
      click_edit_link
      expect_content "Save Tile"
      #pending 'Convert this part controller spec'
      #FIXME expect_mixpanel_action_ping('Tile Preview Page - Archive', 'Clicked Edit button')
    end

   it "should ping on clicking back to tiles button" do
      pending 'Convert to controller spec'
      click_link "Back to Tiles"
      expect_mixpanel_action_ping('Tile Preview Page - Archive', 'Clicked Back to Tiles button')
    end

    it "should ping on clicking new tile button" do
      pending 'Convert to controller spec'
      click_link "New Tile"

      expect_mixpanel_action_ping('Tile Preview Page - Archive', 'Clicked New Tile button')
    end

    it "should ping on clicking archive button" do
      pending 'Convert to controller spec'
      click_link "Post Again"

      expect_mixpanel_action_ping('Tile Preview Page - Archive', 'Clicked Re-post button')
    end

    it "should not show a deactivate link" do
      within "#stat_change_sub" do
        expect_no_deactivate_link
      end
    end
  end

  context "a draft tile" do
    before do
      @tile = FactoryGirl.create(:multiple_choice_tile, status: Tile::DRAFT)
      @client_admin = FactoryGirl.create(:client_admin, demo: @tile.demo)
      visit client_admin_tiles_path(as: @client_admin)
      within "#draft.manage_section" do
        page.find("#single-tile-#{@tile.id} .tile-wrapper a.tile_thumb_link").click
      end
      page.find("#stat_toggle").click
    end

    it "should allow the tile to be activated" do
      within status_change_sub do
        click_reactivate_link
      end
      expect_tile_to_section_change "#draft.manage_section", "#active_tiles"
    end


    it "should link to the edit page" do
      pending 'Convert to controller spec'
      click_edit_link
      expect_mixpanel_action_ping('Tile Preview Page - Draft', 'Clicked Edit button')
    end

    it "should ping on clicking back to tiles button" do
      pending 'Convert to controller spec'
      click_link "Back to Tiles"
      expect_mixpanel_action_ping('Tile Preview Page - Draft', 'Clicked Back to Tiles button')
    end

    it "should ping on clicking new tile button" do
      pending 'Convert to controller spec'
      click_link "New Tile"
      expect_mixpanel_action_ping('Tile Preview Page - Draft', 'Clicked New Tile button')
    end
  end





  def link_with_exact_text(text)
    page.all("a", text: /\A#{text}\z/)
  end

  def link_with_text(text)
    page.all("a", text: text)
  end

  def click_activate_link
    page.find("a", text: "Post").trigger("click");
  end

  def click_reactivate_link
    page.find("a", text: "Post").trigger("click");
  end

  def click_deactivate_link
    page.find("a", text: "Archive").click
  end

  def click_edit_link
    within('.tile_preview_menu') {click_link "Edit"}
  end

  def activate_links
    link_with_exact_text("Post")
  end

  def reactivate_links
    link_with_text("Repost")
  end

  def deactivate_links
    link_with_text('Archive')
  end

  def expect_activate_link
    activate_links.should_not be_empty
  end

  def expect_reactivate_link
    reactivate_links.should_not be_empty
  end

  def expect_deactivate_link
    deactivate_links.should_not be_empty
  end

  def expect_no_activate_link
    activate_links.should be_empty
  end

  def expect_no_deactivate_link
    deactivate_links.should be_empty
  end

  def expect_activated_content(tile)
    expect_content "The #{tile.headline} tile has been published"
  end

  def expect_deactivated_content(tile)
    expect_content "The #{tile.headline} tile has been archived"
  end

  def status_change_sub
    "#stat_change_sub"
  end

  def expect_mixpanel_action_ping(event, action)
    FakeMixpanelTracker.clear_tracked_events
    crank_dj_clear
    properties = {action: action}
    FakeMixpanelTracker.should have_event_matching(event, properties)
  end


  def expect_tile_to_section_change from, to
    selector = "#single-tile-#{@tile.id} .tile-wrapper a.tile_thumb_link"
     within from do
       expect(page).to_not have_css selector
     end
     within to do
       expect(page).to have_css selector
     end
  end
end
