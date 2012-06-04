require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "Talking Chicken Tutorial", %q{
  In order to ...
  As a ...
  I want to ...
} do


  background do
    demo = FactoryGirl.create(:demo, :name => "Hell on Wheels")
    user = FactoryGirl.create(:user, :name => "Brand New", :demo_id => demo.id)
    FactoryGirl.create(:claimed_user, :name => Tutorial.example_search_name, :demo_id => demo.id)
    FactoryGirl.create(:tutorial, :user_id => user.id, :current_step => 4) 
    has_password(user, "foobar")
    signin_as(user, "foobar")
    visit '/users'
  end
  scenario 'only Advance to step 5 if search results show up' do
    page.should have_content("Just for practice, type \"Kermit\", then click FIND!")
    # Search for something that will return no results
    fill_in "search_string", :with => "nonsense"
    click_button("Find!")
    page.should have_content("Just for practice, type \"Kermit\", then click FIND!")
    # Search for a valid user
    fill_in "search_string", :with => "kermit"
    click_button("Find!")
    page.should have_content("Click ADD TO FRIENDS to connect with Kermit")
    # Go back to /users page (not having searched for anything)
    visit '/users'
    page.should have_content("Just for practice, type \"Kermit\", then click FIND!")
  end
  
  
end
