require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "User Chooses To Be Remembered Or Not" do

  def expiration_message
    "Your session has expired. Please log back in to continue."
  end

  before do
    @user = Factory :user
    has_password(@user, 'foobar')

    visit signin_page
    fill_in_signin_fields(@user, 'foobar')
  end

  scenario "User wants to be remembered" do
    check "session[remember_me]"
    click_button "Let's play!"
    should_be_on activity_page

    Timecop.travel(1.month)
    visit activity_page
    should_be_on activity_page
    page.should_not have_content(expiration_message)

    Timecop.travel(18.months)
    visit activity_page
    should_be_on activity_page
    page.should_not have_content(expiration_message)
  end

  scenario "User does not want to be remembered" do
    click_button "Let's play!"
    should_be_on activity_page

    Timecop.travel(4.minutes)
    visit activity_page
    should_be_on activity_page
    page.should_not have_content(expiration_message)

    Timecop.travel(4.minutes)
    visit activity_page
    should_be_on activity_page
    page.should_not have_content(expiration_message)

    Timecop.travel(6.minutes)
    visit activity_page
    should_be_on signin_page
    page.should have_content(expiration_message)
  end
end
