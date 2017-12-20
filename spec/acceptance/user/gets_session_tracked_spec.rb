require 'acceptance/acceptance_helper'
# FIXME: NICK to HERBY Revisit after Mixpanel audit.  Moving to controller specs was too involved. Instead, turned off delayed jobs and removed 
feature "activity session tracking" do
  before do
    user = FactoryBot.create(:user, email: 'fred@foobar.com')
    user.password = user.password_confirmation = "foobar"
    user.save!
    Timecop.freeze
  end

  after(:each) do
    Timecop.return
  end

  let (:threshold) {ApplicationController::ACTIVITY_SESSION_THRESHOLD}

  def do_real_login
    Delayed::Worker.delay_jobs = false

    visit new_session_path
    fill_in "session[email]", with: "fred@foobar.com"
    fill_in "session[password]", with: "foobar"

    FakeMixpanelTracker.clear_tracked_events

    click_button "Log In"
  end

  context "when a user signs in" do
    it "should log a new activity session" do
      do_real_login
      expect(FakeMixpanelTracker).to have_event_matching('Activity Session - New')
    end
  end

  context "when a user does something that triggers authorize after #{ApplicationController::ACTIVITY_SESSION_THRESHOLD} seconds or more" do
    it "should log a new activity session" do
      do_real_login
      FakeMixpanelTracker.clear_tracked_events

      Timecop.travel(threshold - 1)
      visit acts_path
      expect(FakeMixpanelTracker).not_to have_event_matching('Activity Session - New')

      Timecop.travel(threshold)
      visit acts_path
      expect(FakeMixpanelTracker.events_matching('Activity Session - New').size).to eq(1)

      Timecop.travel(threshold + 1)
      visit acts_path
      expect(FakeMixpanelTracker.events_matching('Activity Session - New').size).to eq(2)
    end
  end
end
