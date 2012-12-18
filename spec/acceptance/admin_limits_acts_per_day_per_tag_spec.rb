require 'acceptance/acceptance_helper'
metal_testing_hack(SmsController)

feature 'Admin limits acts per day per tag' do
  after(:each) { Timecop.return }

  it "should do what it says on the label" do
    tag = FactoryGirl.create(:tag, daily_limit: 3)
    other_tag = FactoryGirl.create(:tag)

    first_tag_rules = []
    3.times do
      rule = FactoryGirl.create(:rule, demo_id: nil)
      FactoryGirl.create(:rule_value, rule: rule, is_primary: true)
      rule.tags << tag
      first_tag_rules << rule
    end

    other_tag_rules = []
    3.times do
      rule = FactoryGirl.create(:rule, demo_id: nil)
      FactoryGirl.create(:rule_value, rule: rule, is_primary: true)
      rule.tags << other_tag
      other_tag_rules << rule
    end

    base_time = Chronic.parse("2012-12-18 00:00 EST")
    almost_midnight = base_time + 23.hours + 59.minutes
    tomorrow_midnight = base_time + 24.hours
    Timecop.freeze(base_time)

    user = FactoryGirl.create(:user_with_phone)
    (first_tag_rules + other_tag_rules).each do |rule|
      mo_sms user.phone_number, rule.primary_value.value
    end

    FakeTwilio.sent_messages.each{|sent_message| sent_message['Body'].should include("Points")}
    expect_no_mt_sms_including user.phone_number, "Sorry"

    first_tag_rules.each do |rule|
      FakeTwilio.clear_messages
      mo_sms user.phone_number, rule.primary_value.value
      expect_mt_sms user.phone_number, "Sorry, you've done as many of that kind of action as you can do today."
    end
    other_tag_rules.each do |rule|
      FakeTwilio.clear_messages
      mo_sms user.phone_number, rule.primary_value.value
      expect_mt_sms_including user.phone_number, "Points"
      expect_no_mt_sms_including user.phone_number, "Sorry"
    end

    Timecop.freeze(almost_midnight)
    first_tag_rules.each do |rule|
      FakeTwilio.clear_messages
      mo_sms user.phone_number, rule.primary_value.value
      expect_mt_sms user.phone_number, "Sorry, you've done as many of that kind of action as you can do today."
    end
    other_tag_rules.each do |rule|
      FakeTwilio.clear_messages
      mo_sms user.phone_number, rule.primary_value.value
      expect_mt_sms_including user.phone_number, "Points"
      expect_no_mt_sms_including user.phone_number, "Sorry"
    end

    Timecop.freeze(tomorrow_midnight)
    FakeTwilio.clear_messages
    first_tag_rules.each do |rule|
      mo_sms user.phone_number, rule.primary_value.value
    end
    FakeTwilio.sent_messages.each{|sent_message| sent_message['Body'].should include("Points")}
    expect_no_mt_sms_including user.phone_number, "Sorry"
  end
end
