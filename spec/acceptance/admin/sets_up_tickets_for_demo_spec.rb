require 'acceptance/acceptance_helper'

feature 'Admin sets up tickets for demo', :js => true do
  scenario "should show raffle entries(tickets)" do
    demo = FactoryGirl.create(:demo, :with_tickets)
    user = FactoryGirl.create(:user, :claimed, demo: demo, tickets: 25)
    @raffle = demo.raffle = FactoryGirl.create(:raffle, :live, demo: demo)
    has_password(user, 'foobar')
    visit activity_path(as: user)
    expect_raffle_entries(25)
  end
end
