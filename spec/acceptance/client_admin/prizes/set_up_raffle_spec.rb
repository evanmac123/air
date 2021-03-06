require 'acceptance/acceptance_helper'

feature 'Create raffle', js: true do
  let (:client_admin) { FactoryBot.create(:client_admin)}
  let (:demo)         { client_admin.demo }

  before(:each) do
    FactoryBot.create(:tile, demo: demo, activated_at: DateTime.current) #to active demo
    visit client_admin_prizes_path(as: client_admin)
  end

  scenario 'fill some fields and save as draft' do
    start_date = to_calendar_format(DateTime.current + 1.day)
    end_date = to_calendar_format(DateTime.current - 7.days) #so end date is invalid and will be erased

    fill_in "Start", with: start_date
    fill_in "End", with: end_date
    fill_in_other_info "Other info"
    click_add_prize
    click_add_prize
    fill_in_prize 0, "Prize1"
    fill_in_prize 2, "Prize3"

    click_save_draft

    expect_content "Saved"

  end

  scenario 'fill all fields and start raffle' do
    fill_prize_form
    click_start_raffle
    expect_content("Prize setup successfully")
  end

  scenario "get error when try to start raffle with empty form" do
    click_start_raffle
    expect_content "Sorry, we couldn't start the prize: start date can't be blank, end date can't be blank, should have at least one prize."
  end
end
