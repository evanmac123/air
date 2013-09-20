require 'acceptance/acceptance_helper'

feature "User proper stuff in masthead" do
  scenario "User sees their first name, avatar and score in the masthead" do
    user = FactoryGirl.create :user, :name => "John Fitzgerald Kennedy", :avatar_file_name => 'ein_berliner.jpg', :points => 1234
    has_password(user, "foobar")

    signin_as(user, "foobar")
    should_be_on activity_path(:format => :html)

    within('#welcome-text') { page.should have_content "Hi John" }
    within('#bar_xp') { page.should have_content "1,234 Experience pts" }
    expect_avatar_in_masthead('ein_berliner.png')
  end
end
