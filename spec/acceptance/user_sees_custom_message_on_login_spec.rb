require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "User Sees Custom Message On Login" do

  scenario "User sees a custom message on login" do
    demo = Factory :demo, :login_announcement => "Eat Yr Fuckin Raisins"
    user = Factory :user, :demo => demo
    has_password(user, 'foobar')

    signin_as user, "foobar"
    page.should have_content("Eat Yr Fuckin Raisins")

    visit "/activity"
    page.should_not have_content("Eat Yr Fuckin Raisins")
  end
end
