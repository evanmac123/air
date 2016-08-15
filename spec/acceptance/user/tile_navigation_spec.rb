require 'acceptance/acceptance_helper'

feature 'User navigates to different tiles' do

  let(:demo)    { FactoryGirl.create :demo }
  let(:user)    { FactoryGirl.create :user, :claimed, demo: demo }

  let!(:tile_1) { FactoryGirl.create :tile, demo: demo }
  let!(:tile_2) { FactoryGirl.create :tile, demo: demo }
  let!(:tile_3) { FactoryGirl.create :tile, demo: demo }

  before(:each) do
    bypass_modal_overlays(user)
  end

  background do
    UserIntro.any_instance.stubs(:displayed_first_tile_hint).returns(true)
    signin_as(user, user.password)
  end

  scenario "clicking tiles in the carousel and next- and previous-tile arrows display the correct tiles", js: true do
    visit activity_path
    click_carousel_tile(tile_2)
    expect_current_tile_id(tile_2)

    show_previous_tile
    expect_current_tile_id(tile_3)

    show_previous_tile
    expect_current_tile_id(tile_1)

    show_previous_tile
    expect_current_tile_id(tile_2)

    show_next_tile
    expect_current_tile_id(tile_1)

    visit activity_path
    click_carousel_tile(tile_1)
    expect_current_tile_id(tile_1)
  end
end
