require 'acceptance/acceptance_helper'

feature 'Admin manually completes tile for user' do

  scenario 'should work', :js => true do
    demo = FactoryGirl.create(:demo)
    1.upto(4) {|i| FactoryGirl.create(:tile, name: "Tile #{i}", headline: "Tile #{i}", demo: demo)}

    Prerequisite.create!(prerequisite_tile: Tile.find_by_name("Tile 1"), tile: Tile.find_by_name("Tile 2"))
    Prerequisite.create!(prerequisite_tile: Tile.find_by_name("Tile 3"), tile: Tile.find_by_name("Tile 4"))

    # Tutorial is getting in the way of some of the things we want to do on
    # the page, so we use the trick where we let the tail wag the dog: we
    # create the tutorial first rather than the user.
    tutorial = FactoryGirl.create(:tutorial, ended_at: Time.now)
    user = tutorial.user
    user.update_attributes(accepted_invitation_at: Time.now, demo: demo, phone_number: "+14155551212")
    has_password user, "foobar"
    crank_dj_clear

    signin_as user, 'foobar'
    expect_content "Tile 1"
    expect_content "Tile 3"
    expect_no_content "Tile 2"
    expect_no_content "Tile 4"

    signin_as_admin
    visit edit_admin_demo_user_path(demo, user)
    click_button "Complete Tile 1 for James Earl Jones"

    expect_button "Complete Tile 2 for James Earl Jones"
    expect_button "Complete Tile 3 for James Earl Jones"
    expect_no_button "Complete Tile 1 for James Earl Jones"
    expect_no_button "Complete Tile 4 for James Earl Jones"

    signin_as user, 'foobar'
    visit activity_path
    click_link 'Enter Site'
    expect_content "Tile 2"
    expect_content "Tile 3"
    expect_no_content "Tile 1"
    expect_no_content "Tile 4"
  end

end
