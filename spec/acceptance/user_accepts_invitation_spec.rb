require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "User Accepts Invitation" do

  scenario "User gets logged in only when accepting invitation, not when at acceptance form" do
    user = Factory :user

    visit invitation_page(user)
    visit activity_page
    should_be_on(signin_page)
    visit invitation_page(user)


    fill_in_required_invitation_fields
    click_button 'Join the game'
    should_be_on(activity_page)
  end
end
