require 'acceptance/acceptance_helper'

feature 'User flags act' do
  def click_flag_icon(act = nil)
    link_path = if act
                  link_path_for_act(act)
                else
                  'span.flag a'
                end

    flag_link = page.find(:css, link_path)
    flag_link.click
  end

  def link_path_for_act(act)
    "a#flag_#{act.id}"
  end

  before do
    @demo = FactoryGirl.create(:demo)
    @cheating_user = FactoryGirl.create(:user, demo: @demo, privacy_level: 'everybody')
    @user = FactoryGirl.create(:user, demo: @demo)
    @act = FactoryGirl.create(:act, user: @cheating_user, text: "Hey kids!")

    bypass_modal_overlays(@user)
  end

  context "when the act is on the first page" do
    before do
      visit activity_path(as: @user)
    end

    scenario 'it gets reported to Mixpanel', js: true do
      click_flag_icon
      crank_dj_clear
      FakeMixpanelTracker.events_matching("flagged act").should be_present
    end
  end

  context "when the act is on a later page" do
    before do
      extra_acts = []
      7.downto(1) do |i|
        extra_acts << FactoryGirl.create(:act, user: @cheating_user, text: "Hey kids!", created_at: Time.now - i.minutes)
      end

      @second_page_act = extra_acts.first
      visit activity_path(as: @user)
    end

    scenario 'it gets reported to Mixpanel', js: true do
      page.all(:css, link_path_for_act(@second_page_act)).should be_empty

      click_link "see-more"
      click_flag_icon @second_page_act

      crank_dj_clear
      FakeMixpanelTracker.events_matching("flagged act").should be_present
    end
  end
end
