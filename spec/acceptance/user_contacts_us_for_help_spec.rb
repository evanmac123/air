require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "User Contacts Us For Help" do
  scenario "through the contact us modal", :js => true do

    # Note: This test requires an internet connection to pass
    # Note: We are constraining the user id so that it always shows up as the 
    # same user in Intercom.io
    TEST_SUITE_USER_ID = 999999
    WIDGET = "#IntercomDefaultWidget"
    begin
      # Destroy the user if already exists
      User.find(TEST_SUITE_USER_ID).destroy
    rescue
    end
    user = FactoryGirl.create(:user, 
                              id: TEST_SUITE_USER_ID, 
                              name: "User From Test Suite", 
                              email: TEST_SUITE_USER_ID.to_s + '@sunni.ru')  
    has_password(user, "foobar")
    signin_as(user, "foobar")

    # Set environment variable so Intercom will load
    # Note that we are calling this at the last possible moment, otherwise
    # poltergeist will throw an error because we clicked something taking us to 
    # another page before it had a chance to load the intercom widget
    ENV['INTERCOM'] = 'something, anything'

    page.find('.nav-help').trigger('click')
    20.times do
      unless page.has_css? WIDGET
        puts "waiting for WIDGET to appear on the page"
        sleep 1
      end
    end
    page.find(WIDGET).click
    page.should have_content "Ask us a question or offer suggestions"
    ENV.delete('INTERCOM')
  end
end
