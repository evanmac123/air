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

    bypass_modal_overlays(@kendra)
    signin_as(@kendra, 'milking')

    @first_tile_link = "/tiles/#{@make_toast.id}"
  end

  scenario 'views tile image', js: true do
    # Click on the first tile, and it should take you to the tiles  path
    page.find("a[href='#{@first_tile_link}'] #tile-thumbnail-#{@make_toast.id}").click

    should_be_on tiles_path
    expect_content "Tile: 1 of 2"
    expect_content "My Profile"

    page.find(".tile_holder##{@make_toast.id}").should be_visible
    page.find(".tile_holder##{@discover_fire.id}").should_not be_visible

    page.find("#next").click

    find(".tile_holder##{@discover_fire.id}").should be_visible
    sleep 1
    find(".tile_holder##{@make_toast.id}").should_not be_visible

    expect_content "Tile: 2 of 2"
  end

  context "when a tile has no attached link address" do
    before(:each) do
      @make_toast.link_address.should be_blank
    end

    scenario "it should not be wrapped in a link" do
      visit tiles_path
      toast_image = page.find("img[@alt='make toast']")
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
      visit tiles_path
      toast_image = page.find("img[@alt='make toast']")
      parent = page.find(:xpath, toast_image.path + "/..")

      parent.tag_name.should == "a"
      parent.click
      should_be_on edit_account_settings_path
    end
  end
end
