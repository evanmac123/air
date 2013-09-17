require 'acceptance/acceptance_helper'

feature 'User views tile' do
  before(:each) do
    @demo = FactoryGirl.create(:demo)
    @kendra = FactoryGirl.create(:user, demo_id: @demo.id, password: 'milking')

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
    page.find("#tile-thumbnail-#{@discover_fire.id}").click
    should_be_on tiles_path

    expect_current_tile_id(@discover_fire)
    page.find("#next").click
    expect_current_tile_id(@make_toast)
  end

  scenario 'sees counter', js: true do
    visit tiles_path
    expect_content "Tile 1 of 2"

    page.find("#next").click
    expect_content "Tile 2 of 2"

    page.find("#next").click
    expect_content "Tile 1 of 2"

    page.find("#prev").click
    expect_content "Tile 2 of 2"

    page.find("#prev").click
    expect_content "Tile 1 of 2"
  end

  scenario "it should have the right position when you click to a non-first tile", js: true do
    page.find("#tile-thumbnail-#{@make_toast.id}").click
    expect_no_content "Tile 1 of 2"
    expect_content    "Tile 2 of 2"
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

  context "when a tile has an attached link address" do
    before(:each) do
      @make_toast.update_attributes(link_address: edit_account_settings_url) # easier to test with some internal path
    end

    scenario "it should be wrapped in a link to that address" do
      visit tile_path(@make_toast)
      toast_image = page.find("img[alt='make toast']")
      parent = page.find(:xpath, toast_image.path + "/..")

      parent.tag_name.should == "a"
      parent.click
      should_be_on edit_account_settings_path
    end
  end
end
