require 'acceptance/acceptance_helper'

feature "Site admin makes an ordinary user into a client admin" do
  it "sends an appropriate ping" do
    peon = FactoryGirl.create(:user)
    visit edit_admin_demo_user_path(peon.demo, peon.slug, as: an_admin)
    check "user[is_client_admin]"
    click_button "Update User"

    FakeMixpanelTracker.clear_tracked_events
    crank_dj_clear
    FakeMixpanelTracker.should have_event_matching('claimed account', {source: 'Site Admin'})
  end

  it "sends no ping if the client admin status is not changed" do
    peon = FactoryGirl.create(:user)
    visit edit_admin_demo_user_path(peon.demo, peon.slug, as: an_admin)
    click_button "Update User"

    FakeMixpanelTracker.clear_tracked_events
    crank_dj_clear
    FakeMixpanelTracker.should_not have_event_matching('Creator - New')
  end
end
