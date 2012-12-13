require 'acceptance/acceptance_helper'

feature 'Admin sets up tickets for demo', :js => true do
  scenario "should do what it says" do
    demo = FactoryGirl.create(:demo)
    signin_as_admin

    visit admin_demo_path(demo)
    expect_content "Game will not use tickets"

    visit edit_admin_demo_path(demo)

    # These guys are hidden and revealed with some JS
    expect_no_content "Points for ticket award"
    expect_no_content "Minimum number of tickets awarded"
    expect_no_content "Maximum number of tickets awarded"
    check "Use tickets"
    expect_content "Points for ticket award"
    expect_content "Minimum number of tickets awarded"
    expect_content "Maximum number of tickets awarded"

    fill_in "Points for ticket award", :with => '10'
    fill_in "Minimum number of tickets awarded", :with => 5
    fill_in "Maximum number of tickets awarded", :with => 7

    click_button "Update Game"

    expect_content "Game will use tickets"
    expect_content "Tickets are awarded every 10 points (5 to 7 tickets awarded at a time)"
  end

  scenario "should show tickets in the header" do
    demo = FactoryGirl.create(:demo, :with_tickets)
    user = FactoryGirl.create(:user, :claimed, demo: demo, tickets: 25)
    has_password(user, 'foobar')
    signin_as(user, 'foobar')
    expect_ticket_header(25)
  end
end

feature "Admin doesn't turn on tickets for demo" do
  it "should not show tickets in the header" do
    demo = FactoryGirl.create(:demo)
    demo.uses_tickets.should_not be_true

    user = FactoryGirl.create(:user, :claimed, demo: demo)
    has_password(user, 'foobar')

    signin_as user, 'foobar'
    expect_no_content "tickets"
  end
end
