require 'acceptance/acceptance_helper'

feature 'Gets remembered when logging in via digest link' do
  let(:user) {FactoryGirl.create(:user)}

  after(:each) do
    Timecop.return
  end

  def travel_past_login_expiration
    Timecop.freeze(Clearance.configuration.cookie_expiration.call + 1.minute)
  end

  scenario "if it's their first login (i.e. they get their password generated)" do
    user.should_not be_claimed
    visit generate_password_invitation_acceptance_path(user_id: user.id, invitation_code: user.invitation_code)
    should_be_on activity_path

    travel_past_login_expiration
    visit activity_path
    should_be_on activity_path
  end

  scenario "it isn't their first login (i.e. they come in via the activity path)" do
    user.update_attributes(accepted_invitation_at: Time.now)
    visit activity_path(user_id: user.id, tile_token: EmailLink.generate_token(user))
    should_be_on activity_path

    travel_past_login_expiration
    visit activity_path
    should_be_on activity_path
  end
end
