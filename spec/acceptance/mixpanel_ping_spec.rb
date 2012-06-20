require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')


feature "Make sure mixpanel pings fire" do
  before do
    @user = FactoryGirl.create(:user)
  end

  scenario "view invitation acceptance page" do
    visit invitation_path(@user.invitation_code)
    crank_dj_clear
    FakeMixpanelTracker.should have_event_matching("viewed page", @user.data_for_mixpanel.merge(:page_name => 'invitation acceptance'))
  end
end
