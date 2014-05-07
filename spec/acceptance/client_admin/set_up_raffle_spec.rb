require 'acceptance/acceptance_helper'

feature 'Create raffle' do
  let (:client_admin) { FactoryGirl.create(:client_admin)}
  let (:demo)         { client_admin.demo }

  before(:each) do
    FactoryGirl.create(:tile, demo: demo, activated_at: DateTime.now) #to active demo
    visit client_admin_prizes_path(as: client_admin)
  end

  scenario 'fill some fields and save as draft', js: true do
    start_date = to_calendar_format(DateTime.now)
    end_date = to_calendar_format(DateTime.now - 7.days) #so end date is invalid and will be erased

    fill_in "Start", with: start_date
    fill_in "End", with: end_date
    fill_in_other_info "Other info"
    click_add_prize
    click_add_prize
    fill_in_prize 0, "Prize1"
    fill_in_prize 2, "Prize3"

    click_save_draft

    expect_content "Saved"

    raffle = demo.raffle
    raffle.starts_at.should == to_start_date(start_date)
    raffle.prizes.should == ["Prize1", "Prize3"]
    raffle.other_info.should == "Other info"
    raffle.ends_at.should be_nil
  end

  scenario 'fill all fields and start raffle', js: true do
    fill_prize_form
    click_start_raffle

    raffle = demo.raffle
    raffle.starts_at.should == to_start_date(DateTime.now)
    raffle.ends_at.should == to_end_date(DateTime.now + 7.days)
    raffle.prizes.should == ["Prize2", "Prize3"]
    raffle.other_info.should == "Other info"
    raffle.status.should == Raffle::LIVE
  end

  scenario "get error when try to start raffle with empty form", js: true do
    click_start_raffle
    expect_content "Sorry, we couldn't start the raffle: start date can't be blank, end date can't be blank, should have at least one prize."
  end

  scenario "clear form", js: true do
    fill_prize_form
    click_clear_form
    click_start_raffle
    expect_content "Sorry, we couldn't start the raffle: start date can't be blank, end date can't be blank, should have at least one prize."
  end
end