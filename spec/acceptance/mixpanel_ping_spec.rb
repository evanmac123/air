require 'acceptance/acceptance_helper'


feature "Make sure mixpanel pings fire" do
  before do
    @user = FactoryGirl.create(:user)
    @phone = "8838848838"
    @pass = "phobasil"
  end

  scenario "view invitation acceptance page", :js => true do
    visit invitation_path(@user.invitation_code)
    crank_dj_clear
    @user.should be_pinged_on_page('invitation acceptance')
    fill_in 'user_new_phone_number', :with => @phone
    fill_in 'user_password', :with => @pass
    fill_in 'user_password_confirmation', :with => @pass
    check 'user_terms_and_conditions'
    click_button 'join_the_game_link'
    page.should have_content('Home')  # This just makes sure page has refreshed already
    crank_dj_clear
    @user.reload # Reload so it can pick up the join date, or it will fail the next line
    @user.should be_pinged_on_page('interstitial phone verification')
    fill_in 'user_new_phone_validation', :with => @user.reload.new_phone_validation
    click_button 'Validate phone'
    page.should have_content('Invite your friends')# This just makes sure page has refreshed already
    crank_dj_clear
    @user.should be_pinged_on_page('invite friends modal')
    @user.should_not be_pinged_on_page('talking chicken')
    @user.should_not be_pinged_on_page('activity feed')
    click_link 'show_me_the_site'
    sleep 1
    crank_dj_clear
    @user.should be_pinged_on_page('talking chicken')
    @user.should_not be_pinged_on_page('activity feed')
    click_link 'no_thanks_tutorial'
    crank_dj_clear
    @user.should be_pinged_on_page('activity feed')
  end
end
