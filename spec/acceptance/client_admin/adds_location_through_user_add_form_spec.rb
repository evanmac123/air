require 'acceptance/acceptance_helper'

feature 'Adds location through user add form' do
  scenario "by choosing the magic value from the Location select", js: true do
    client_admin = FactoryGirl.create(:client_admin)
    FactoryGirl.create :tile, demo: client_admin.demo
    visit client_admin_users_path(as: client_admin)

    demo = client_admin.demo
    demo.locations.length.should == 0

    click_link 'More options'
    select "Add new...", from: "user[location_id]"
    fill_in "New location name", with: "Funkytown"
    click_button "Save new location"

    fill_in "user[name]", with: "Mayor McCheese"
    click_button "Add User"

    # This next line is to ensure that the HTTP request actually finishes before 
    # we go poke around in the database again.
    #
    # File that piece of knowldege in Things I Have Learned The Hard Way 
    # (Vol. 74)

    page.should have_content("OK, we've added Mayor McCheese")

    demo.users.reload.length.should == 2 # new guy + existing admin
    demo.reload.locations.length.should == 1
    demo.users.find_by_name("Mayor McCheese").location.name.should == "Funkytown"
  end
end
