require 'acceptance/acceptance_helper'

feature 'Activates or edits tile from preview page' do
  def activate_link_text
    "Activate this tile"  
  end

  def deactivate_link_text
    "Deactivate this tile"  
  end

  def edit_link_text
    "Edit this tile"
  end

  def links_with_text(text)
    page.all("a", text: text)
  end

  def click_activate_link
    click_link activate_link_text
  end

  def click_deactivate_link
    click_link deactivate_link_text
  end

  def click_edit_link
    click_link edit_link_text
  end

  def activate_links
    links_with_text(activate_link_text)
  end

  def deactivate_links
    links_with_text(deactivate_link_text)
  end

  def expect_activate_link
    activate_links.should_not be_empty
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
    expect_content "The #{tile.headline} tile has been activated"
  end

  def expect_deactivated_content(tile)
    expect_content "The #{tile.headline} tile has been archived"
  end

  context "an active tile" do
    before do
      @tile = FactoryGirl.create(:multiple_choice_tile, status: Tile::ACTIVE)
      @client_admin = FactoryGirl.create(:client_admin, demo_id: @tile.demo_id)

      visit client_admin_tile_path(@tile, as: @client_admin)
    end

    it "should allow the tile to be deactivated" do
      click_deactivate_link

      should_be_on client_admin_tile_path(@tile)
      expect_deactivated_content(@tile)
      expect_activate_link
      expect_no_deactivate_link

      @tile.reload.status.should == Tile::ARCHIVE
    end

    it "should link to the edit page" do
      click_edit_link
      should_be_on edit_client_admin_tile_path(@tile)
    end

    it "should not show an activate link" do
      expect_no_activate_link
    end
  end

  context "an inactive tile" do
    before do
      @tile = FactoryGirl.create(:multiple_choice_tile, status: Tile::ARCHIVE)
      @client_admin = FactoryGirl.create(:client_admin, demo_id: @tile.demo_id)

      visit client_admin_tile_path(@tile, as: @client_admin)
    end

    it "should allow the tile to be activated" do
      click_activate_link

      should_be_on client_admin_tile_path(@tile)
      expect_activated_content(@tile)
      expect_deactivate_link
      expect_no_activate_link

      @tile.reload.status.should == Tile::ACTIVE
    end

    it "should link to the edit page" do
      click_edit_link
      should_be_on edit_client_admin_tile_path(@tile)
    end

    it "should not show a deactivate link" do
      expect_no_deactivate_link
    end
  end
end
