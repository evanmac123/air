require 'acceptance/acceptance_helper'
include SteakHelperMethods

feature "flash messages only display a single time" do
  before(:each) do
    # Session count is set to keep the "Get started" lightbox out of the way
    @fred = FactoryGirl.create(:user, name: 'Fred', password: 'foobar', session_count: 3)
    signin_as(@fred, 'foobar')
  end

  scenario "single use", js: true do
    command = 'nonsense'
    response = "I don't understand"
    visit acts_path
    fill_in 'command_central', with: command
    click_play_button
    # here is the flash
    page.should have_content(response)
    # Now revisite the page, and the flash should still be there
    visit acts_path
    page.should_not have_content(response)

    fill_in 'command_central', with: command
    click_play_button

    page.should have_content(response)

    # Close the flash manually
    page.find('#close-flash').trigger('click')
    page.find("#close-flash").visible? == false
    # Revisit the page, and the flash should be gone
    visit acts_path
    page.should_not have_content(response)
  end
end
