require 'acceptance/acceptance_helper'

feature 'Admin sets up gold coins for demo', :js => true do
  scenario "should do what it says" do
    demo = FactoryGirl.create(:demo)
    signin_as_admin

    visit admin_demo_path(demo)
    expect_content "Game will not use gold coins"

    visit edit_admin_demo_path(demo)

    # These guys are hidden and revealed with some JS
    expect_no_content "Points for gold coin award"
    expect_no_content "Minimum number of gold coins awarded"
    expect_no_content "Maximum number of gold coins awarded"
    check "Use gold coins"
    expect_content "Points for gold coin award"
    expect_content "Minimum number of gold coins awarded"
    expect_content "Maximum number of gold coins awarded"

    fill_in "Points for gold coin award", :with => '10'
    fill_in "Minimum number of gold coins awarded", :with => 5
    fill_in "Maximum number of gold coins awarded", :with => 7

    click_button "Update Game"

    expect_content "Game will use gold coins"
    expect_content "Gold coins are awarded every 10 points (5 to 7 coins awarded at a time)"
  end

  scenario "should show gold coins in the header"
end

feature "Admin doesn't turn on gold coins for demo" do
  it "should not show gold coins in the header" do
    demo = FactoryGirl.create(:demo)
    demo.uses_gold_coins.should_not be_true

    user = FactoryGirl.create(:user, :claimed, demo: demo)
    has_password(user, 'foobar')

    signin_as user, 'foobar'
    expect_no_content "Gold coins"
  end
end
