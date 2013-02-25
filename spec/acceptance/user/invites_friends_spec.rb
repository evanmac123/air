require 'acceptance/acceptance_helper'

feature 'User invites friends' do
  scenario "invitation modal pops up on first two logins", js: true do
    user = FactoryGirl.create(:user, :claimed, session_count: 0)
    has_password user, 'foobar'
    signin_as user, 'foobar'
    within('#facebox') do
      expect_content 'Invite your friends'
    end

    # Second time around, same thing...
    signin_as user, 'foobar'
    within('#facebox') do
      expect_content 'Invite your friends'
    end

    # But the third time...
    signin_as user, 'foobar'
    page.all('#facebox').should be_empty
  end
end
