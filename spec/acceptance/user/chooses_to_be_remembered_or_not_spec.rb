require 'acceptance/acceptance_helper'

feature "User Chooses To Be Remembered Or Not" do
  include SessionHelpers

  before do
    @user = FactoryBot.create :user
    has_password(@user, 'foobar')

    visit signin_page
    fill_in_signin_fields(@user, 'foobar')
  end

  scenario "User wants to be remembered" do
    click_button "Log In"
    should_be_on activity_path

    Timecop.travel(1.month)
    visit activity_path
    should_be_on activity_path
    expect(page).not_to have_content(logged_out_message)

    Timecop.travel(10.months)
    visit activity_path
    should_be_on activity_path
    expect(page).not_to have_content(logged_out_message)
    Timecop.return
  end

  scenario "User does not want to be remembered" do
    uncheck "session[remember_me]"
    click_button "Log In"
    should_be_on activity_path

    Timecop.travel(19.minutes)
    visit activity_path
    should_be_on activity_path
    expect(page).not_to have_content(logged_out_message)

    Timecop.travel(19.minutes)
    visit activity_path
    should_be_on activity_path
    expect(page).not_to have_content(logged_out_message)

    Timecop.travel(50.minutes)
    visit activity_path
    should_be_on signin_page
    expect(page).to have_content(logged_out_message)
    Timecop.return
  end
end
