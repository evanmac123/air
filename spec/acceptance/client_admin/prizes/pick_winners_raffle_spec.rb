require 'acceptance/acceptance_helper'

feature 'Pick winners after raffle' do
  let (:client_admin) { FactoryGirl.create(:client_admin)}
  let (:demo)         { client_admin.demo }

  before(:each) do
    FactoryGirl.create(:tile, demo: demo, activated_at: DateTime.now) #to active demo
    @users = FactoryGirl.create_list(:user, 4, :with_tickets, demo: demo)
  end

  context "pick all list of winners", js: true do
    before(:each) do
      @raffle = demo.raffle = FactoryGirl.create(:raffle, :pick_winners, demo: demo)
      visit client_admin_prizes_path(as: client_admin)
    end

    scenario "pick some number of winners!", js: true do
      demo.reload.raffle.reload.status == Raffle::PICK_WINNERS
      click_pick_winners 3

      demo.reload.raffle.reload.status == Raffle::PICKED_WINNERS
      demo.raffle.winners.count.should == 3
    end

    scenario "get message if no potential winners left", js: true do
      click_pick_winners 4
      demo.reload.raffle.reload.status == Raffle::PICKED_WINNERS
      demo.raffle.winners.count.should == 4
      expect_no_content "No one has tickets or you've already drawn all potential winners."

      click_pick_winners 1
      demo.reload.raffle.reload.status == Raffle::PICKED_WINNERS
      demo.raffle.winners.count.should == 0
      expect_content "No one has tickets or you've already drawn all potential winners."
    end
  end

  context "re-pick one winner" do
    before(:each) do
      @raffle = demo.raffle = FactoryGirl.create(:raffle, :picked_winners, demo: demo)
      demo.raffle.add_winners @users[0..1]
      visit client_admin_prizes_path(as: client_admin)
    end

    scenario "delete one winner", js: true do
      deleted_winner = User.find_by_email winner_email(1)
      delete_winner 1
      @raffle.reload.winners.include?(deleted_winner).should be_false
    end

    scenario "re-pick one winner", js: true do
      ejected_winner = User.find_by_email winner_email(1)
      repick_winner 1
      @raffle.reload.winners.include?(ejected_winner).should be_false
      @raffle.reload.blacklisted_users.include?(ejected_winner).should be_true
    end

    scenario "re-pick winner and get message if no potential winners left", js: true do
      3.times do #until last winner in the list left
        repick_winner 0
        expect_no_content "No one has tickets or you've already drawn all potential winners."
      end

      repick_winner 0
      expect_content "No one has tickets or you've already drawn all potential winners."
    end
  end
end