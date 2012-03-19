require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "User Sends Email Info Request", %q{
  In order to find out what this H Engage thing is
  As a random yahoo with a browser
  I want to ask for information
} do

  scenario "User requests information through the marketing page", :js => true do
    visit marketing_page
 
    fill_in "email[name]", :with => "James Hennessey IX"
    fill_in "email[email]", :with => "james@henhen.com"
    within('#bottom-comment-box') do
      page.find(:css, "input[@type=image]").click
    end

    page.should have_content "Thanks, we'll be in touch"

    crank_dj

    open_email 'vlad@hengage.com'
    email_body.should include("James Hennessey IX")
    email_body.should include("james@henhen.com")
  end
end
