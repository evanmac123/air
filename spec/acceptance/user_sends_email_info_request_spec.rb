require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "User Sends Email Info Request", %q{
  In order to find out what this H Engage thing is
  As a random yahoo with a browser
  I want to ask for information
} do

  scenario "User requests information through the marketing page", :js => true do
    EmailInfoRequest.stubs(:"create!")

    @phone = "(332) 334-3322"
    @name = "James Hennessey IX"
    @email = "somthingfornothing@james.com"
    @comment = "You guys kick serious a$$"
    visit marketing_page
    click_link "Contact us"
 
    fill_in "contact_name", :with => @name
    fill_in "contact_email", :with => @email
    fill_in "contact_phone", :with => @phone
    fill_in "contact_comment", :with => @comment
    click_button "contact-submit"

    page.should have_content "Thanks! We'll be in touch"
    crank_dj_clear

    EmailInfoRequest.should have_received(:"create!").with(email: @email, name: @name, phone: @phone, comment: @comment)
  end
end
