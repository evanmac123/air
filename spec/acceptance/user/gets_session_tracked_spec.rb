require 'acceptance/acceptance_helper'

feature "activity session tracking" do
  before do
    user = FactoryGirl.create(:user, email: 'fred@foobar.com')
    user.password = user.password_confirmation = "foobar"
    user.save!
    Timecop.freeze
  end

  after(:each) do
    Timecop.return
  end

  let (:threshold) {ApplicationController::ACTIVITY_SESSION_THRESHOLD} # this would get real tedious to type

  def do_real_login
    # We want to exercise the #authorize method, so we can't use the backdoor
    # in these tests.
    visit new_session_path
    fill_in "session[email]", with: "fred@foobar.com"
    fill_in "session[password]", with: "foobar"

    crank_dj_clear
    FakeMixpanelTracker.clear_tracked_events

    click_button "Log In"
  end

  context "when a user signs in" do
    it "should log a new activity session" do
      pending 'Convert to controller spec'
      do_real_login
      crank_dj_clear
      FakeMixpanelTracker.should have_event_matching('Activity Session - New')
    end
  end

  context "when a user does something that triggers authorize after #{ApplicationController::ACTIVITY_SESSION_THRESHOLD} seconds or more" do
    it "should log a new activity session" do
      pending 'Convert to controller spec'
      do_real_login
      crank_dj_clear
      FakeMixpanelTracker.clear_tracked_events

      Timecop.travel(threshold - 1)
      visit acts_path
      crank_dj_clear
      FakeMixpanelTracker.should_not have_event_matching('Activity Session - New')

      Timecop.travel(threshold)
      visit acts_path
      crank_dj_clear
      FakeMixpanelTracker.events_matching('Activity Session - New').should have(1).ping

      Timecop.travel(threshold + 1)
      visit acts_path
      crank_dj_clear
      FakeMixpanelTracker.events_matching('Activity Session - New').should have(2).pings
    end
  end
end
