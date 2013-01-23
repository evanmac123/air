require 'acceptance/acceptance_helper'

feature 'User flags act' do
  before do
    @demo = FactoryGirl.create(:demo)
    @cheating_user = FactoryGirl.create(:user, demo: @demo, privacy_level: 'everybody')
    @user = FactoryGirl.create(:user, demo: @demo)
    @act = FactoryGirl.create(:act, user: @cheating_user, text: "Hey kids!")

    bypass_modal_overlays(@user)
    visit activity_path(as: @user)
    click_link "Flag"
  end

  scenario 'and it gets reported to Mixpanel', js: true do
    expected_mixpanel_properties = {
      user_id:    @user.id,
      suspect_id: @cheating_user.id,
      act_id:     @act.id
    }

    crank_dj_clear
    FakeMixpanelTracker.events_matching("flagged act").should be_present#, expected_mixpanel_properties).should be_present
  end

  scenario 'and the link text changes', js: true do
    within '.flag' do
      expect_content 'Flagged'
    end
  end
end
