require 'acceptance/acceptance_helper'

feature 'Admin edits tile' do
  before(:each) do
    @demo = FactoryGirl.create(:demo)
    ['bake bread', 'discover fire', 'domesticate cattle', 'make toast'].each do |tile_name|
      FactoryGirl.create(:tile, name: tile_name, demo: @demo)
    end

    @make_toast = Tile.find_by_name('make toast')
    @make_toast.update_attributes(start_time: Time.parse('2015-05-01 08:00:00 UTC'))
    Prerequisite.create(tile: @make_toast, prerequisite_tile: Tile.find_by_name('bake bread'))
    Prerequisite.create(tile: @make_toast, prerequisite_tile: Tile.find_by_name('discover fire'))
    
    signin_as_admin
    visit edit_admin_demo_tile_path(@demo, @make_toast)
  end

  scenario 'tweaking the basic settings' do
    fill_in "Name", :with => "Make roast beef"
    unselect "bake bread", :from => "Prerequisite tiles"
    select "domesticate cattle", :from => "Prerequisite tiles"
    fill_in "Start time", :with => "April 17, 2012, 3:25 PM"
    click_button "Update Tile"

    expect_no_content "make toast"
    expect_content "Make roast beef"
    expect_content "domesticate cattle"
    expect_content "Apr 17, 2012 @ 03:25 PM"
  end

  scenario 'tweaking completion triggers' do
    FactoryGirl.create(:rule_value, is_primary: true, rule: (FactoryGirl.create(:rule, reply: 'did 1', demo: @demo)), value: 'do 1')
    FactoryGirl.create(:rule_value, is_primary: true, rule: (FactoryGirl.create(:rule, reply: 'did 2', demo: @demo)), value: 'do 2')
    FactoryGirl.create(:survey, name: 'Survey 1', demo: @demo)
    FactoryGirl.create(:survey, name: 'Survey 2', demo: @demo)
    
    visit edit_admin_demo_tile_path(@demo, @make_toast)

    choose 'AND'
    select 'do 1', :from => 'Rules'
    select 'Survey 1', :from => 'Survey'
    click_button 'Update Tile'

    expect_content 'make toast'
    expect_content 'discover fire'
    expect_content 'May 01, 2015 @ 04:00 AM'
    expect_content 'do 1'
    expect_content 'Survey 1'

    click_link 'make toast'
    select 'do 2', :from => 'Rules'
    select 'Survey 2', :from => 'Survey'
    click_button 'Update Tile'

    expect_content 'make toast'
    expect_content 'discover fire'
    expect_content 'May 01, 2015 @ 04:00 AM'
    expect_content 'do 2'
    expect_content 'Survey 2'
  end

  scenario 'uploading a new image' do
    attach_file "tile[image]", tile_fixture_path('cov1.jpg')
    click_button 'Update Tile'
    expect_content 'cov1.jpg'

    click_link 'make toast'
    attach_file "tile[image]", tile_fixture_path('cov2.jpg')
    click_button 'Update Tile'
    expect_content 'cov2.jpg'
  end

  scenario 'deleting the image' do
    attach_file "tile[image]", tile_fixture_path('cov1.jpg')
    click_button 'Update Tile'
    expect_content 'cov1.jpg'

    click_link 'make toast'
    expect_link "cov1.jpg", Tile.last.image.url
    click_button 'Remove image'
    
    should_be_on admin_demo_tiles_path(@demo)
    expect_no_content 'cov1.jpg'
  end

  scenario "uploading a new thumbnail" do
    attach_file "tile[thumbnail]", tile_fixture_path('cov1_thumbnail.jpg')
    click_button 'Update Tile'
    expect_content 'cov1_thumbnail.jpg'

    click_link 'make toast'
    attach_file "tile[thumbnail]", tile_fixture_path('cov2_thumbnail.jpg')
    click_button 'Update Tile'
    expect_content 'cov2_thumbnail.jpg'
  end

  scenario "deleting the thumbnail" do
    attach_file "tile[thumbnail]", tile_fixture_path('cov1_thumbnail.jpg')
    click_button 'Update Tile'
    expect_content 'cov1_thumbnail.jpg'

    click_link 'make toast'
    click_button 'Remove thumbnail'
    
    should_be_on admin_demo_tiles_path(@demo)
    expect_no_content 'cov1_thumbnail.jpg'
  end
end
