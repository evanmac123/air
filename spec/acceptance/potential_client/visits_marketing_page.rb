require 'acceptance/acceptance_helper'

feature 'Visits marketing page' do
  def expect_marketing_blurb
    expect_content "Create communications that drive employee engagement in any program, benefit, training or process."  
  end

  context "as not user" do
    before(:each) do
      visit marketing_page
    end
    scenario "and see page" do
      expect_marketing_blurb
    end

    scenario "pings Marketing page with has_ever_logged_in=false" do
      FakeMixpanelTracker.clear_tracked_events
      crank_dj_clear
      FakeMixpanelTracker.should have_event_matching("viewed page", page_name: "Marketing Page", has_ever_logged_in: false )
    end
  end

  context "as User" do 
    before(:each) do
      @user = FactoryGirl.create(:user)
      visit activity_path(as: @user)
      click_link "Sign Out"
      visit marketing_page
    end

    scenario "and see page" do
      expect_marketing_blurb
    end 

    scenario "pings Marketing page" do
      FakeMixpanelTracker.clear_tracked_events
      crank_dj_clear
      FakeMixpanelTracker.should have_event_matching("viewed page", \
        {page_name: "Marketing Page", has_ever_logged_in: true}.merge(@user.data_for_mixpanel) )
    end
  end

  context "as Guest User" do 
    before(:each) do
      @public_demo = FactoryGirl.create(:demo, :with_public_slug)
      visit public_board_path(@public_demo.public_slug)
      visit marketing_page
    end

    scenario "and see page" do
      expect_marketing_blurb
    end 

    scenario "pings Marketing page" do
      @user = GuestUser.last
      FakeMixpanelTracker.clear_tracked_events
      crank_dj_clear
      FakeMixpanelTracker.should have_event_matching("viewed page", \
       {page_name: "Marketing Page", has_ever_logged_in: true}.merge(@user.data_for_mixpanel) )
    end
  end
end
