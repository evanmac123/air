require 'acceptance/acceptance_helper'

feature 'Client admin gets limited access by token' do
  scenario "to the explore page, when the token is appended as a query parameter" do
    user = FactoryGirl.create(:client_admin)
    visit explore_path(explore_token: user.explore_token)

    should_be_on explore_path
  end

  scenario "to the explore page, when the token was set some time in the past"
end
