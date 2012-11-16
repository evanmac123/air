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
    
    # Click on the first tile, and it should take you to the tiles  path
    first_tile_link = "/tiles?start=#{@make_toast.id}"
    page.find("a[href='#{first_tile_link}'] #tile-thumbnail-#{@make_toast.id}").click
  end

  scenario 'views tile image', js: :webkit do
    current_path.should == tiles_path
    expect_content "Tile: 1 of 2"
    expect_content "MY PROFILE"

    page.find("img##{@make_toast.id}").should be_visible
    page.find("img##{@discover_fire.id}").should_not be_visible

    # Click the "next" button
    page.find("#next").click
    wait_until { page.find("img##{@discover_fire.id}").visible? }
    wait_until { not page.find("img##{@make_toast.id}").visible? }
    expect_content "Tile: 2 of 2"
  end
end
