require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "Talking Chicken Tutorial", %q{
  In order to ...
  As a ...
  I want to ...
} do


  background do
    demo = Factory(:demo, :name => "Hell on Wheels")
    user = Factory(:user, :name => "Brand New", :demo_id => demo.id)
    Factory(:claimed_user, :name => "Alice in Wonderland", :demo_id => demo.id)
    Factory(:tutorial, :user_id => user.id, :current_step => 4) 
    has_password(user, "foobar")
    signin_as (user, "foobar")
    visit '/users'
  end
  scenario 'only Advance to step 5 if search results show up' do
    page.should have_content("For example, type \"alice\", then click FIND!")
    # Search for something that will return no results
    fill_in "search_string", :with => "nonsense"
    click_button("Find!")
    page.should have_content("For example, type \"alice\", then click FIND!")
    # Search for a valid user
    fill_in "search_string", :with => "Alice"
    click_button("Find!")
    page.should have_content("Click \"Follow\" to befriend Alice")
    # Go back to /users page (not having searched for anything)
    visit '/users'
    page.should have_content("For example, type \"alice\", then click FIND!")
  end
  
  
end
