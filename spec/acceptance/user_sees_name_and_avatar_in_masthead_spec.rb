require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "User Sees Name And Avatar In Masthead" do

  scenario "User sees their first name and avatar in the masthead" do
    user = FactoryGirl.create :user, :name => "John Fitzgerald Kennedy", :avatar_file_name => 'ein_berliner.jpg'
    has_password(user, "foobar")

    signin_as(user, "foobar")
    should_be_on activity_path(:format => :html)

    within('.masthead') do
      page.should have_content "Welcome back, John"
      expect_avatar48('ein_berliner.png')
    end

  end
end
