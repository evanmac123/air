require 'acceptance/acceptance_helper'

feature 'Creates board' do
  scenario 'sends an appropriate ping' do
    pending "Convert to controller spec"
    visit new_admin_demo_path(as: an_admin)
    fill_in "demo[name]", with: "Awesomesauce Board"
    click_button "Create Game"
    
    FakeMixpanelTracker.clear_tracked_events
    crank_dj_clear
    FakeMixpanelTracker.should have_event_matching("Boards - New", source: 'Site Admin')
  end
end
