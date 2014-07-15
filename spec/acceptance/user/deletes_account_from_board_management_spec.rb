require 'acceptance/acceptance_helper'

feature 'Deletes account from board management' do
  include BoardSettingsHelpers

  let(:user) {FactoryGirl.create :user}

  it "by deleting their only board", js: true do
    has_password(user, "foobar")
    user.demos.should have(1).board

    visit activity_path(as: user)
    open_board_settings
    wait_for_board_modal

    click_last_delete_link
    complete_safety_modal

    should_be_on "/"

    visit activity_path
    should_be_on sign_in_path
    signin_as user, "foobar"
    page.should have_content("Sorry, that's an invalid username or password.")
  end

  it "has appropriate copy in the safety modal", js: true do
    visit activity_path(as: user)
    open_board_settings
    wait_for_board_modal

    click_last_delete_link

    within(safety_modal_selector) do
      page.should have_content("Your account will be permanently deleted from Airbo.")
    end
  end
end
