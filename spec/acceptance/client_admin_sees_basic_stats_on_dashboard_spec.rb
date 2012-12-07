require 'acceptance/acceptance_helper'

feature 'Client admin sees basic stats on dashboard' do
  context "with a small number of users" do
    before do
      demo = signin_as_client_admin.demo
      2.times {FactoryGirl.create :user, :claimed, demo: demo}
      5.times {FactoryGirl.create :user, :claimed, :with_phone_number, demo: demo}
      7.times {FactoryGirl.create :user, :claimed, :with_game_referrer, demo: demo}
      10.times {FactoryGirl.create :user, demo: demo}

      # That makes 24 total, 14 claimed
    end

    it "should include the number of claimed users" do
      visit client_admin_path
      expect_content "14 Participants"
    end

    it "should include the percentage of users with mobile phones" do
      visit client_admin_path
      expect_content "36% Added mobile numbers"
    end

    it "should include the percentage of users who credited a game referrer" do
      visit client_admin_path
      expect_content "50% Joined via peer"
    end
  end

  context "when there are 1000 or more claimed users" do
    before do
      Demo.any_instance.stubs(:claimed_user_count).returns(123456)
    end

    it "should display the number of claimed users in a prettier way" do
      signin_as_client_admin.demo
      visit client_admin_path
      expect_content "123,456 Participants" # notice the comma
    end
  end
end
