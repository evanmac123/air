require 'acceptance/acceptance_helper'

feature "User Chooses To Be Remembered Or Not" do

  def expiration_message
    "Your session has expired. Please log back in to continue."
  end

  before do
    @user = FactoryGirl.create :user
    has_password(@user, 'foobar')

    visit signin_page
    fill_in_signin_fields(@user, 'foobar')
  end

  scenario "User wants to be remembered" do
    click_button "Let's play!"
    should_be_on activity_path(:format => :html)
    
    Timecop.travel(1.month)
    visit activity_path
    should_be_on activity_path
    page.should_not have_content(expiration_message)

    Timecop.travel(10.months)
    visit activity_path
    should_be_on activity_path
    page.should_not have_content(expiration_message)
    Timecop.return
  end

  scenario "User does not want to be remembered" do
    uncheck "session[remember_me]"
    click_button "Let's play!"
    should_be_on activity_path(format: :html)

    Timecop.travel(19.minutes)
    visit activity_path
    should_be_on activity_path
    page.should_not have_content(expiration_message)

    Timecop.travel(19.minutes)
    visit activity_path
    should_be_on activity_path
    page.should_not have_content(expiration_message)

    Timecop.travel(50.minutes)
    visit activity_path
    should_be_on signin_page
    page.should have_content(expiration_message)
    Timecop.return
  end
end
