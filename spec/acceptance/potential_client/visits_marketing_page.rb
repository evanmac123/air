require 'acceptance/acceptance_helper'

feature 'Visits marketing page' do
  scenario "and see page" do
    visit marketing_page
    expect_content "Highlight important information to employees in a fun and interactive way."
  end

  scenario "pings Marketing page with has_ever_logged_in=false" do
    visit marketing_page
    FakeMixpanelTracker.clear_tracked_events
    crank_dj_clear
    p session
    FakeMixpanelTracker.should have_event_matching("viewed page", page_name: "Marketing Page", has_ever_logged_in: false )
  end
end