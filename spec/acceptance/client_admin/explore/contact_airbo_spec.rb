require 'acceptance/acceptance_helper'

feature "Client admin contacts airbo" do
  let! (:client_admin) {a_client_admin}

  context "clicks 'contact airbo' button" do
    before do
      p client_admin.user_intro
      visit explore_path(as: client_admin)
      page.find("#contact-airbo").click
    end

    it "should send ping", js: true, driver: :webkit do
      pending "Convert to Controller spec"
      FakeMixpanelTracker.clear_tracked_events
      crank_dj_clear
      FakeMixpanelTracker.should have_event_matching('Explore page - Interaction', "action"=>"Clicked \"Contact Airbo\" button")
    end
  end
end
