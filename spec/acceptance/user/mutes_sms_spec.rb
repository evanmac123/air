require 'acceptance/acceptance_helper'

feature 'Mutes sms' do
  let(:user) { FactoryGirl.create(:user, :with_phone_number, notification_method: "both") }

  after(:each) do
    Timecop.return
  end

  def mute_notification
    "If you want to temporarily stop getting texts from us, you can text back MUTE to stop them for 24 hours. To stop getting this reminder, text OK."
  end

  def expect_mute_reminder_after_texts(user, triggering_count)
    (triggering_count - 1).times do
      SMS.send_message user, "hi"
      user.reload
    end

    crank_dj_clear
    expect_no_mt_sms user.phone_number, mute_notification

    SMS.send_message user, "hi"
    crank_dj_clear
    expect_mt_sms user.phone_number, mute_notification
  end

  scenario "by sending in MUTE" do
    SMS.send_message(user, "Text 1")
    SMS.send_message(user, "Text 2")
    crank_dj_clear

    mo_sms(user.phone_number, "mute")
    crank_dj_clear

    # Muting lasts for 24 hours, so these won't be received.
    # Must reload the user or else it will seem to be un-muted.
    user.reload
    SMS.send_message(user, "Text 3")
    Timecop.travel(12.hours.from_now)
    SMS.send_message(user, "Text 4")
    crank_dj_clear

    Timecop.travel(12.hours.from_now)
    # And now 24 hours have passed so we should get these
    SMS.send_message(user, "Text 5")
    Timecop.travel(12.hours.from_now)
    SMS.send_message(user, "Text 6")
    crank_dj_clear

    ["Text 1", "Text 2", "Text 5", "Text 6"].each do |expected_text|
      expect_mt_sms user.phone_number, expected_text
    end

    ["Text 3", "Text 4"].each do |unexpected_text|
      expect_no_mt_sms user.phone_number, unexpected_text
    end

    expect_mt_sms user.phone_number, "OK, you won't get any more texts from us for at least 24 hours."
  end

  scenario "gets mute reminder after 10 texts" do
    expect_mute_reminder_after_texts(user, 10)
  end

  scenario "reminder threshold can be set on a custom basis" do
    user.demo.update_attributes(mute_notice_threshold: 3)
    expect_mute_reminder_after_texts(user, 3)
  end

  scenario "texts OK to stop getting mute reminder" do
    9.times do
      SMS.send_message user, "hi"
      user.reload
    end
    crank_dj_clear

    expect_no_mt_sms user.phone_number, mute_notification

    mo_sms user.phone_number, "ok"
    user.reload

    SMS.send_message user, "hi"
    crank_dj_clear

    expect_no_mt_sms user.phone_number, mute_notification
  end

  scenario "gets texts about muting only, not e-mails" do
    ActionMailer::Base.deliveries.should be_empty
    10.times do
      SMS.send_message user, "hi"
      user.reload
    end
    crank_dj_clear

    ActionMailer::Base.deliveries.should be_empty
  end
end
