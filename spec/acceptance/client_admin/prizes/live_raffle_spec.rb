require 'acceptance/acceptance_helper'

feature 'Live raffle' do
  let (:client_admin) { FactoryBot.create(:client_admin)}
  let (:demo) { client_admin.demo }

  before(:each) do
    FactoryBot.create(:tile, demo: demo, activated_at: Time.current)
    demo.raffle = FactoryBot.create(:raffle, :live, demo: demo)
    binding.pry
    visit client_admin_prizes_path(as: client_admin)
    binding.pry
  end

  scenario "edit raffle in live", js: true do
    expect(demo.raffle.status).to eq(Raffle::LIVE)
    click_edit_raffle
    fill_prize_form
    click_save_live_raffle

    raffle = demo.raffle.reload

    expect(raffle.prizes).to eq(["Prize2", "Prize3"])
    expect(raffle.other_info).to eq("Other info")
  end

  scenario "cancel raffle", js: true do
    click_cancel_raffle
    expect(demo.reload.raffle.status).to eq(Raffle::SET_UP)
  end

  scenario "end early raffle", js: true do
    click_link_end_early
    expect(demo.reload.raffle.status).to eq(Raffle::PICK_WINNERS)
  end
end
