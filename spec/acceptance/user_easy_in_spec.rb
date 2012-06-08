require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "An easy in to the site, like having a secret pass" do
    include EmailSpec::Helpers
    include EmailSpec::Matchers

  before(:each) do
    @user = FactoryGirl.create(:user, email: 'dan@example.com')
    @email = Mailer.easy_in(@user)
    @email.should deliver_to(@user.email_with_name)
    @email.should have_subject "Wondering what your colleagues are up to in #{@user.demo.name}? Here's an easy way to take a peek"
    @email.deliver

  end

  scenario "Leah is brought straight to the Talking Chicken Slide 1"  do
    open_email(@user.email)
    regex = /invitation/
    click_email_link_matching(regex)
    page.body.should include "Step 1 of 7"
  end

  scenario "Leah can set a password" do
    open_email(@user.email)
    regex = /password/
    click_email_link_matching(regex)
    page.body.should include "Choose a Password"
  end
end
