require 'acceptance/acceptance_helper'

feature 'Search for user in directory has character minimum' do
  scenario 'which will reprimand the user if they try to use too few' do
    user = FactoryGirl.create(:user)
    has_password user, 'foobar'

    FactoryGirl.create(:user, :claimed, name: "John", demo: user.demo)
    FactoryGirl.create(:user, :claimed, name: "Janice", demo: user.demo)
    FactoryGirl.create(:user, :claimed, name: "Johann", demo: user.demo)

    signin_as user, 'foobar'
    visit users_path
    fill_in 'search bar', :with => 'n'
    click_button "Find!"

    expect_no_content "John"
    expect_no_content "Janice"
    expect_no_content "Johann"
    expect_content "Please enter at least 3 letters to search on if you'd like to search"
  end
end
