require 'acceptance/acceptance_helper'

feature "Guest user activity session tracking" do
  pending "move this to a controller spec"
  let (:board) { FactoryGirl.create(:demo, is_public: true) }
  let (:threshold) {ApplicationController::ACTIVITY_SESSION_THRESHOLD}

  before(:each) do
    Delayed::Worker.delay_jobs = false
    FakeMixpanelTracker.clear_tracked_events
  end

  context "when a public board is first visited" do
    it "should log a new activity session" do
      visit public_board_path(board.public_slug)

      FakeMixpanelTracker.should have_event_matching('Activity Session - New', {user_type: 'guest'})
    end
  end

  context "when a user does something that triggers authorize after #{ApplicationController::ACTIVITY_SESSION_THRESHOLD} seconds or more" do
    before do
      Timecop.freeze
    end

    after(:each) do
      Timecop.return
    end

    it "should long a new activity session" do
      visit public_board_path(board.public_slug)
      FakeMixpanelTracker.clear_tracked_events

      Timecop.travel(threshold - 1)

      visit public_board_path(board.public_slug)

      FakeMixpanelTracker.should_not have_event_matching('Activity Session - New')

      Timecop.travel(threshold)

      visit public_board_path(board.public_slug)

      FakeMixpanelTracker.events_matching('Activity Session - New', {user_type: 'guest'}).should have(1).ping

      Timecop.travel(threshold + 1)

      visit public_board_path(board.public_slug)

      FakeMixpanelTracker.events_matching('Activity Session - New', {user_type: 'guest'}).should have(2).pings
    end
  end
end
