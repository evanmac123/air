require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "User Contacts Us For Help" do
  scenario "through the contact us modal", :js => true do
    $ASSISTLY_CALLED = false

    user = FactoryGirl.create :user
    has_password(user, "foobar")
    signin_as(user, "foobar")

    page.find('.nav-help').trigger('click')
    page.find(".contact_us_link").click
    $ASSISTLY_CALLED.should be_true
  end
end
