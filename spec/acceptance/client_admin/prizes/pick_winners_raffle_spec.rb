require 'acceptance/acceptance_helper'

feature 'Pick winners after raffle', js: true do
  let (:client_admin) { FactoryBot.create(:client_admin)}
  let (:demo)         { client_admin.demo }

  before(:each) do
    FactoryBot.create(:tile, demo: demo, activated_at: DateTime.current) #to active demo
    @users = FactoryBot.create_list(:user, 4, :with_tickets, demo: demo)
  end

  context "pick all list of winners" do
    before(:each) do
      @raffle = demo.raffle = FactoryBot.create(:raffle, :pick_winners, demo: demo)
      visit client_admin_prizes_path(as: client_admin)
    end

    scenario "pick some number of winners!" do
      click_pick_winners 3

      expect(demo.raffle.winners.count).to eq(3)
    end

    scenario "get message if no potential winners left" do
      click_pick_winners 4

      expect(demo.raffle.winners.count).to eq(4)
      expect_no_content "No one has tickets or you've already drawn all potential winners."

      click_pick_winners 1

      expect(demo.raffle.winners.count).to eq(0)
      expect_content "No one has tickets or you've already drawn all potential winners."
    end
  end
end
