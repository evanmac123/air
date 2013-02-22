require 'acceptance/acceptance_helper'

feature 'Admin sets up tickets for demo', :js => true do
  scenario "should do what it says" do
    demo = FactoryGirl.create(:demo)
    visit edit_admin_demo_path(demo, as: an_admin)
    expect_content "Points for ticket award"

    fill_in "Points for ticket award", :with => '10'

    click_button "Update Game"

    expect_content "Game will use tickets"
    expect_content "Tickets are awarded every 10 points"
  end

  scenario "should show tickets in the header" do
    demo = FactoryGirl.create(:demo, :with_tickets)
    user = FactoryGirl.create(:user, :claimed, demo: demo, tickets: 25)
    has_password(user, 'foobar')
    visit activity_path(as: user)
    expect_ticket_header(25)
  end
end

feature "Admin doesn't turn on tickets for demo" do
  it "should not show tickets in the header" do
    demo = FactoryGirl.create(:demo)
    demo.uses_tickets.should be_true

    user = FactoryGirl.create(:user, :claimed, demo: demo)
    has_password(user, 'foobar')

    signin_as user, 'foobar'
    expect_no_content "tickets"
  end
end
