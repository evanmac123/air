require 'acceptance/acceptance_helper'

feature 'Client admin segments on characteristics' do
  before do
    admin = FactoryGirl.create :client_admin
    bypass_modal_overlays(admin)
    signin_as(admin, admin.password)

    demo = admin.demo
    demo_specific_characteristic = FactoryGirl.create(:characteristic, :discrete, demo: demo, name: 'Favorite Pancake', allowed_values: %w(blueberry strawberry kitten))
    game_agnostic_characteristic = FactoryGirl.create(:characteristic, :number, name: "IQ")

    FactoryGirl.create(:user, :claimed, points: 20, demo: demo, characteristics: {demo_specific_characteristic.id => 'strawberry', game_agnostic_characteristic.id => 87})
    FactoryGirl.create(:user, :claimed, points: 25, demo: demo, characteristics: {demo_specific_characteristic.id => 'blueberry', game_agnostic_characteristic.id => 137})
    FactoryGirl.create(:user, :claimed, points: 30, demo: demo, characteristics: {demo_specific_characteristic.id => 'blueberry', game_agnostic_characteristic.id => 87})

    crank_dj_clear
    visit client_admin_segmentation_path
  end

  scenario 'can segment on dummy characteristic', js: true do
    select "Points", :from => "segment_column[0]"
    select "is less than", :from => "segment_operator[0]"
    fill_in "segment_value[0]", :with => "28"
    click_button "Find segment"

    expect_content "SEGMENTED BY CHARACTERISTICS: Points is less than 28"
    expect_content "USERS IN SEGMENT 3"
  end

  scenario 'can segment on game-agnostic characteristic', js: true do
    select "IQ", :from => "segment_column[0]"
    select "is greater than", :from => "segment_operator[0]"
    fill_in "segment_value[0]", :with => '100'
    click_button "Find segment"

    expect_content "SEGMENTED BY CHARACTERISTICS: IQ is greater than 100"
    expect_content "USERS IN SEGMENT 1"
  end

  scenario 'segmenting on game-specific characteristic', js: true do
    select "Favorite Pancake", :from => "segment_column[0]"
    select "equals", :from => "segment_operator[0]"
    select "blueberry", :from => "segment_value[0]"
    click_button "Find segment"

    expect_content "SEGMENTED BY CHARACTERISTICS: Favorite Pancake equals blueberry"
    expect_content "USERS IN SEGMENT 2"
  end

  scenario "doesn't see Show Users links", js: true do
    select "Points", :from => "segment_column[0]"
    select "is less than", :from => "segment_operator[0]"
    fill_in "segment_value[0]", :with => "28"
    click_button "Find segment"

    expect_content "SEGMENTED BY CHARACTERISTICS: Points is less than 28"
    expect_no_content "Show users"
  end
end
