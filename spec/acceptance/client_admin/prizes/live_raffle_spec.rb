require 'acceptance/acceptance_helper'

feature 'Live raffle' do
  let (:client_admin) { FactoryGirl.create(:client_admin)}
  let (:demo)         { client_admin.demo }

  before(:each) do
    FactoryGirl.create(:tile, demo: demo, activated_at: DateTime.now) #to active demo
    demo.raffle = FactoryGirl.create(:raffle, :live, demo: demo)
    visit client_admin_prizes_path(as: client_admin)
  end

  scenario "edit raffle in live", js: true do
    demo.raffle.status.should == Raffle::LIVE
    click_edit_raffle
    fill_prize_form
    click_save_live_raffle

    raffle = demo.raffle.reload
    raffle.starts_at.should == to_start_date(DateTime.now)
    raffle.ends_at.should == to_end_date(DateTime.now + 7.days)
    raffle.prizes.should == ["Prize2", "Prize3"]
    raffle.other_info.should == "Other info"
  end

  scenario "cancel raffle", js: true do
    click_cancel_raffle
    demo.reload.raffle.status.should == Raffle::SET_UP
  end

  scenario "end early raffle", js: true do
    click_link_end_early
    demo.reload.raffle.status.should == Raffle::PICK_WINNERS
  end
end