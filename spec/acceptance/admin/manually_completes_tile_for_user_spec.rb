require 'acceptance/acceptance_helper'

feature 'Admin manually completes tile for user' do

  scenario 'should work', :js => true do
    demo = FactoryGirl.create(:demo)
    1.upto(4) {|i| FactoryGirl.create(:tile, headline: "Tile #{i}", demo: demo)}

    Prerequisite.create!(prerequisite_tile: Tile.find_by_headline("Tile 1"), tile: Tile.find_by_headline("Tile 2"))
    Prerequisite.create!(prerequisite_tile: Tile.find_by_headline("Tile 3"), tile: Tile.find_by_headline("Tile 4"))

    user = FactoryGirl.create(:user, demo: demo, accepted_invitation_at: Time.now, phone_number: "+14155551212", name: "Johann McGillicuddy")
    has_password user, "foobar"
    crank_dj_clear

    visit activity_path(as: user)
    expect_content "Tile 1"
    expect_content "Tile 3"
    expect_no_content "Tile 2"
    expect_no_content "Tile 4"

    visit edit_admin_demo_user_path(demo, user, as: an_admin)
    click_button "Complete Tile 1 for Johann McGillicuddy"

    expect_button "Complete Tile 2 for Johann McGillicuddy"
    expect_button "Complete Tile 3 for Johann McGillicuddy"
    expect_no_button "Complete Tile 1 for Johann McGillicuddy"
    expect_no_button "Complete Tile 4 for Johann McGillicuddy"

    visit activity_path(as: user)
    expect_content "Tile 2"
    expect_content "Tile 3"
    #completed tiles should show
    expect_content "Tile 1"
    expect_no_content "Tile 4"
  end

end
