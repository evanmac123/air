require 'acceptance/acceptance_helper'

feature 'Activates or edits tile from preview page' do
  def activate_link_text
    "Post"  
  end

  def reactivate_link_text
    "Repost"  
  end

  def deactivate_link_text
    "Archive"  
  end

  def edit_link_text
    "Edit"
  end

  def links_with_text(text)
    page.all("a", text: text)
  end

  def click_activate_link
    click_link activate_link_text
  end
  def click_reactivate_link
    click_link reactivate_link_text
  end

  def click_deactivate_link
    click_link deactivate_link_text
  end

  def click_edit_link
    within('.content') {click_link edit_link_text}
  end

  def activate_links
    links_with_text(activate_link_text)
  end

  def reactivate_links
    links_with_text(reactivate_link_text)
  end

  def deactivate_links
    links_with_text(deactivate_link_text)
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

  def expect_first_time_create_popover
    expect_content 'Click Post to publish your tile.'
    expect_content 'Got It'
  end
  
  def expect_no_first_time_create_popover
    expect_no_content 'Click Post to publish your tile.'
    expect_no_content 'Got It'
  end
  def expect_first_time_post_popover
    expect_content "Congratulations! Your tile is posted."
    expect_content 'Next click Back to Tiles to see your board.'
  end
  
  def expect_no_first_time_post_popover
    expect_no_content "Congratulations! You've posted your first tile."
    expect_no_content 'Next click Back to Tiles to see your board.'
  end
  
  def expect_mixpanel_action_ping(event, action)
    FakeMixpanelTracker.clear_tracked_events
    crank_dj_clear
    properties = {action: action}
    FakeMixpanelTracker.should have_event_matching(event, properties)    
  end
  
  context "an active tile" do
    before do
      @tile = FactoryGirl.create(:multiple_choice_tile, status: Tile::ACTIVE)
      @client_admin = FactoryGirl.create(:client_admin, demo: @tile.demo)

      visit client_admin_tile_path(@tile, as: @client_admin)
    end

    it "should allow the tile to be deactivated" do
      click_deactivate_link

      should_be_on client_admin_tile_path(@tile)
      expect_deactivated_content(@tile)
      expect_reactivate_link
      
      expect_no_deactivate_link

      @tile.reload.status.should == Tile::ARCHIVE
    end

    it "should link to the edit page" do
      click_edit_link
      should_be_on edit_client_admin_tile_path(@tile)
      
      expect_mixpanel_action_ping('Tile Preview Page - Posted', 'Clicked Edit button')
    end
    
    it "should ping on clicking back to tiles button" do
      click_link "Back to Tiles"
      
      expect_mixpanel_action_ping('Tile Preview Page - Posted', 'Clicked Back to Tiles button')
    end
    
    it "should ping on clicking new tile button" do
      click_link "New Tile"
      
      expect_mixpanel_action_ping('Tile Preview Page - Posted', 'Clicked New Tile button')
    end
    
    it "should ping on clicking archive button" do
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

      visit client_admin_tile_path(@tile, as: @client_admin)
    end

    it "should allow the tile to be activated" do
      click_reactivate_link

      should_be_on client_admin_tile_path(@tile)
      expect_activated_content(@tile)
      expect_deactivate_link
      expect_no_activate_link

      @tile.reload.status.should == Tile::ACTIVE
    end

    it "should link to the edit page" do
      click_edit_link
      should_be_on edit_client_admin_tile_path(@tile)
      
      expect_mixpanel_action_ping('Tile Preview Page - Archive', 'Clicked Edit button')
    end
    
    it "should ping on clicking back to tiles button" do
      click_link "Back to Tiles"
      
      expect_mixpanel_action_ping('Tile Preview Page - Archive', 'Clicked Back to Tiles button')
    end
    
    it "should ping on clicking new tile button" do
      click_link "New Tile"
      
      expect_mixpanel_action_ping('Tile Preview Page - Archive', 'Clicked New Tile button')
    end
    
    it "should ping on clicking archive button" do
      click_link "Repost"
      
      expect_mixpanel_action_ping('Tile Preview Page - Archive', 'Clicked Re-post button')
    end
    
    it "should not show a deactivate link" do
      expect_no_deactivate_link
    end
  end
  
  context "a draft tile" do
    before do
      @tile = FactoryGirl.create(:multiple_choice_tile, status: Tile::DRAFT)
      @client_admin = FactoryGirl.create(:client_admin, demo: @tile.demo)

      visit client_admin_tile_path(@tile, as: @client_admin)
    end
    scenario 'should post' do
      click_link 'Post'
      expect_mixpanel_action_ping('Tile Preview Page - Draft', 'Clicked Post button')
    end
    
    scenario "should link to the edit page" do
      click_edit_link      
      expect_mixpanel_action_ping('Tile Preview Page - Draft', 'Clicked Edit button')
    end
    
    scenario "should ping on clicking back to tiles button" do
      click_link "Back to Tiles"      
      expect_mixpanel_action_ping('Tile Preview Page - Draft', 'Clicked Back to Tiles button')
    end
    
    scenario "should ping on clicking new tile button" do
      click_link "New Tile"      
      expect_mixpanel_action_ping('Tile Preview Page - Draft', 'Clicked New Tile button')

    end    
  end
  
  context "first time client admin" do
    before do
      @client_admin = FactoryGirl.create(:client_admin)
      visit new_client_admin_tile_path(as: @client_admin)
    end
    
    scenario "sees the popover appear the first time tile is created in demo which disappears on click", js:true do
      create_good_tile
      
      expect_first_time_create_popover
      click_link 'Got it'

      expect_no_first_time_create_popover
      expect_mixpanel_action_ping('Tile Preview Page - Draft', 'Clicked Got It button in orientation pop-over')
    end

    scenario "does not see the popover appear after first time create", js:true do
      create_existing_tiles(@client_admin.demo, Tile::ACTIVE, 2)
      create_good_tile
      expect_no_first_time_create_popover
    end

    context 'after first tile create' do
      scenario "sees the popover appear the first time tile is posted", js:true do        
        create_good_tile
        click_link 'Post'        
        expect_first_time_post_popover
      end
      scenario "does not see the popover appear after first time post", js:true do
        create_existing_tiles(@client_admin.demo, Tile::ACTIVE, 2)
        create_good_tile
        click_link 'Post'
        expect_no_first_time_post_popover
      end
    end
  end
end
