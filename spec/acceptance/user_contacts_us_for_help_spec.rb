require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "User Contacts Us For Help" do
  scenario "through the contact us modal", :js => true do
    $ASSISTLY_CALLED = false

    user = Factory :user
    has_password(user, "foobar")
    signin_as(user, "foobar")

    click_link "Help"
    page.find(".contact_us_link").click
    $ASSISTLY_CALLED.should be_true
  end
end
