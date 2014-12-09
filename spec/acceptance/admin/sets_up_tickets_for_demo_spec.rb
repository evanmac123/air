require 'acceptance/acceptance_helper'

feature 'Admin sets up tickets for demo', :js => true do
  scenario "should do what it says" do
    demo = FactoryGirl.create(:demo)
    visit edit_admin_demo_path(demo, as: an_admin)
    expect_content "POINTS FOR TICKET AWARD"

    fill_in "Points for ticket award", :with => '10'

    click_button "Update Game"

    expect_content "Game will use tickets"
    expect_content "Tickets are awarded every 10 points"
  end

  scenario "should show raffle entries(tickets)" do
    demo = FactoryGirl.create(:demo, :with_tickets)
    user = FactoryGirl.create(:user, :claimed, demo: demo, tickets: 25)
    @raffle = demo.raffle = FactoryGirl.create(:raffle, :live, demo: demo)
    has_password(user, 'foobar')
    visit activity_path(as: user)
    expect_raffle_entries(25)
  end
end
