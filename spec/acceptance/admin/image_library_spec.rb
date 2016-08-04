require 'acceptance/acceptance_helper'

feature "Site Admin works with Image Library" do
  include WaitForAjax

  scenario "creates image", js: true do
    visit admin_tile_images_path(as: an_admin)
    expect_content "Image Library"
    attach_tile "tile_image[image]", tile_fixture_path('cov1.jpg')
    expect_content "Image was saved"
    page.find_all(".tile_image_block img").length.should == 1

  end

  scenario "deletes image", js: true do
    t1, t2  =   FactoryGirl.create_list(:tile_image, 2)
    visit admin_tile_images_path(as: an_admin)

    within tile_image_block(t1) do
      click_link "Delete"
    end

    expect_content "Image was destroyed"
    page.all(tile_image_selector).count.should == 1
  end
end
