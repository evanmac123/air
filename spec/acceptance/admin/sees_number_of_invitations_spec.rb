require 'acceptance/acceptance_helper'

feature 'Admin sees number of invitations' do
  before(:each) do
    @base_time = Chronic.parse("May 1, 2012, 12:00 PM")
    @demo = FactoryGirl.create(:demo)
    other_demo = FactoryGirl.create(:demo)

    1.upto(10) do |offset|
      invitation = FactoryGirl.create(:peer_invitation, demo: @demo)
      FactoryGirl.create(:peer_invitation, demo: other_demo)

      invitation.update_attributes(created_at: @base_time - offset.hours)
    end

    visit admin_demo_peer_invitations_path(@demo, as: an_admin)
  end

  context 'specifying only a start date' do
    it "should find the correct answer" do
      fill_in "Start at", :with => "May 1, 2012, 3:00 AM"
      click_button "Count invitations"

      expect_content "9 invitations sent"
    end
  end

  context 'specifying only an end date' do
    it "should find the correct answer" do
      fill_in "End at", :with => "May 1, 2012, 5:00 AM"
      click_button "Count invitations"

      expect_content "4 invitations sent"
    end
  end

  context 'specifying both a start date and end date' do
    it "should find the correct answer" do
      fill_in "Start at", :with => "May 1, 2012, 3:00 AM"
      fill_in "End at", :with => "May 1, 2012, 5:00 AM"
      click_button "Count invitations"

      expect_content "3 invitations sent"
    end
  end

  context 'specifying neither a start or end date' do
    it "should find the correct answer" do
      click_button "Count invitations"
      expect_content "10 invitations sent from the beginning of time to just now"
    end
  end
end
