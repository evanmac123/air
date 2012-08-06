require 'acceptance/acceptance_helper'
include SteakHelperMethods

feature "flash messages persist until either another flash message is created to take its place, or until you manually close the flash with the little 'x'" do
  before(:each) do
    @fred = FactoryGirl.create(:user, password: 'foobar')
    signin_as(@fred, 'foobar')
  end

  scenario "persist", js: true do 
    command = 'nonsense'
    visit acts_path
    fill_in 'command_central', with: command
    click_button "Play"
    # here is the flash
    page.should have_content("I don't understand")
    # Now revisite the page, and the flash should still be there
    visit acts_path
    page.should have_content("I don't understand")
    # Close the flash manually
    click_link 'close-flash'
    wait_until {page.find("#close-flash").visible? == false}
    # Revisit the page, and the flash should be gone
    visit acts_path
    page.should_not have_content("I don't understand")
  end
end
