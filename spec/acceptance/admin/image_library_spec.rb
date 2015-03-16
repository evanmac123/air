require 'acceptance/acceptance_helper'

feature "Site Admin works with Image Library" do
  include WaitForAjax

  scenario "creates image", js: true do
    visit admin_tile_images_path(as: an_admin)
    expect_content "Image Library"
    attach_tile "tile_image[image]", tile_fixture_path('cov1.jpg')

    expect_content "Image was saved"
    TileImage.count.should == 1

    ti = TileImage.last
    tile_image_block(ti).should be_present
    # shows gears while resizing
    tile_image_block(ti).find("img")[:src].should =~ /resizing_gears_fullsize/
  end

  scenario "deletes image", js: true do
    FactoryGirl.create_list(:tile_image, 2)
    visit admin_tile_images_path(as: an_admin)
    page.all(tile_image_selector).count.should == 2

    ti = TileImage.first
    within tile_image_block(ti) do
      click_link "Delete"
    end

    expect_content "Image was destroyed"
    page.all(tile_image_selector).count.should == 1
    TileImage.all.include?(ti).should be_false
  end
end