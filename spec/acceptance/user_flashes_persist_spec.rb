require 'acceptance/acceptance_helper'
include SteakHelperMethods

feature "flash messages only display a single time" do
  before(:each) do
    # Create a user, Fred, with a closed tutorial. Tutorial is closed 
    # because when the tutorial is active, we do not persist flashes
    @fred = FactoryGirl.create(:user, name: 'Fred', password: 'foobar')

    # FactoryGirl for some reason creates two users if I create a :claimed users, and 
    # associates the tutorial with the wrong one! So to let the tail wag the dog,
    # I am explicitly creating my tutorial. 
    tutorial = FactoryGirl.create(:tutorial, user: @fred, ended_at: Chronic.parse("January 1, 2011, 5:00 AM"))
    signin_as(@fred, 'foobar')
  end

  scenario "single use", js: true do
    command = 'nonsense'
    response = "I don't understand"
    visit acts_path
    fill_in 'command_central', with: command
    click_button "Play"
    # here is the flash
    page.should have_content(response)
    # Now revisite the page, and the flash should still be there
    visit acts_path
    page.should_not have_content(response)

    fill_in 'command_central', with: command
    click_button "Play"

    page.should have_content(response)

    # Close the flash manually
    click_link 'close-flash'
    wait_until {page.find("#close-flash").visible? == false}
    # Revisit the page, and the flash should be gone
    visit acts_path
    page.should_not have_content(response)
  end
end
