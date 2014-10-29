require 'acceptance/acceptance_helper'

feature 'Clicking back to tiles goes back to the appropriate place' do
  before do
    @client_admin = FactoryGirl.create(:client_admin)
  end

  def click_back_to_tiles
    click_link 'Back to Tiles'
  end

  def click_tile_in_section(section_selector)
    page.find("#{section_selector} .tile_thumb_link").click
  end

  it "takes you back to the main tiles index if you started there" do
    Tile::STATUS.each do |status|
      FactoryGirl.create(:multiple_choice_tile, demo_id: @client_admin.demo_id, status: status)
    end

    visit client_admin_tiles_path(as: @client_admin)

    %w(#draft_tiles #active_tiles #archived_tiles).each do |section_selector|
      click_tile_in_section(section_selector)
      click_back_to_tiles
      should_be_on client_admin_tiles_path
    end
  end

  it "takes you back to the draft page if you started there" do
    FactoryGirl.create(:multiple_choice_tile, demo_id: @client_admin.demo_id, status: Tile::DRAFT)
    visit client_admin_tiles_path(as: @client_admin)
    within('#draft_tiles') {click_link "Show all"}
    click_tile_in_section('#draft_tiles')
    click_back_to_tiles
    should_be_on client_admin_draft_tiles_path
  end

  it "takes you back to the archive page if you started there" do
    FactoryGirl.create(:multiple_choice_tile, demo_id: @client_admin.demo_id, status: Tile::ARCHIVE)
    visit client_admin_tiles_path(as: @client_admin)
    within('#archived_tiles') {click_link "Show all"}
    click_tile_in_section('#archived_tiles')
    click_back_to_tiles
    should_be_on client_admin_inactive_tiles_path
  end
end
