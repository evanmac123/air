require "spec_helper"

include TileHelpers

describe 'Follow-up email scheduled by delayed job' do

  def check_common_dj_attributes(dj_record)
    dj_record.run_at.should == Date.today.midnight.advance(hours: 12)

    dj_record.handler.should include 'TilesDigestMailer'
    dj_record.handler.should include ':notify_all_follow_up'
  end

  #----------------------------------------------------------------------------------

  it 'follow-up records get created when appropriate' do
    # Follow-up doesn't go out if nil (default value for new demo) or 0 (which is == 'never')
    nil_follow_up  = FactoryGirl.create :demo
    zero_follow_up = FactoryGirl.create :demo, follow_up_digest_email_days: 0

    claimed_users = FactoryGirl.create :demo, follow_up_digest_email_days: 1,  unclaimed_users_also_get_digest: false
    all_users     = FactoryGirl.create :demo, follow_up_digest_email_days: 10, unclaimed_users_also_get_digest: true

    user = FactoryGirl.create :claimed_user

    [nil_follow_up, zero_follow_up, claimed_users, all_users].each_with_index do |demo, i|
      user.update_attributes demo: demo

      TilesDigestMailer.notify_all(demo.id, (1..(i + 1)).to_a)  # Make it so tile_ids are different for each digest email

      case i
        when 0 then FollowUpDigestEmail.count.should == 0  # Tile ids would be [1] (if sent out, but not)
        when 1 then FollowUpDigestEmail.count.should == 0  # Tile ids would be [1, 2] (if sent out, but not)
        when 2
          FollowUpDigestEmail.count.should == 1

          followup = FollowUpDigestEmail.first
          followup.demo_id.should == demo.id
          followup.tile_ids.should == [1, 2, 3]
          followup.send_on.should == Date.today + 1.day
          followup.unclaimed_users_also_get_digest.should be_false
        when 3
          FollowUpDigestEmail.count.should == 2

          followup = FollowUpDigestEmail.last
          followup.demo_id.should == demo.id
          followup.tile_ids.should == [1, 2, 3, 4]
          followup.send_on.should == Date.today + 10.days
          followup.unclaimed_users_also_get_digest.should be_true
      end
    end
  end

  # 'TilesDigestMailer#notify_all_follow_up_from_delayed_job' is the method that the cron-job runs once a day.
  # This spec also tests that 'FollowUpDigestEmail#send_follow_up_digest_email' returns the correct follow-up's for a given day.
  #
  it 'follow-up records cause follow-up email to be sent' do
    yesterday      = FactoryGirl.create_list :follow_up_digest_email, 1, send_on: Date.today - 1.day
    tomorrow       = FactoryGirl.create_list :follow_up_digest_email, 2, send_on: Date.today + 1.day
    day_after      = FactoryGirl.create_list :follow_up_digest_email, 3, send_on: Date.today + 2.days
    day_after_that = FactoryGirl.create_list :follow_up_digest_email, 4, send_on: Date.today + 3.days

    # Shouldn't grab any followup's from yesterday or the following days
    TilesDigestMailer.notify_all_follow_up_from_delayed_job
    Delayed::Job.count.should == 0

    Timecop.travel(Date.today + 1.day)
    TilesDigestMailer.notify_all_follow_up_from_delayed_job
    Delayed::Job.count.should == 2

    Delayed::Job.all.each_with_index do |dj_record, i|
      check_common_dj_attributes(dj_record)
      dj_record.handler.should include tomorrow[i].id.to_s
    end

    Delayed::Job.destroy_all

    Timecop.travel(Date.today + 1.day)
    TilesDigestMailer.notify_all_follow_up_from_delayed_job
    Delayed::Job.count.should == 3

    Delayed::Job.all.each_with_index do |dj_record, i|
      check_common_dj_attributes(dj_record)
      dj_record.handler.should include day_after[i].id.to_s
    end

    Delayed::Job.destroy_all

    Timecop.travel(Date.today + 1.day)
    TilesDigestMailer.notify_all_follow_up_from_delayed_job
    Delayed::Job.count.should == 4

    Delayed::Job.all.each_with_index do |dj_record, i|
      check_common_dj_attributes(dj_record)
      dj_record.handler.should include day_after_that[i].id.to_s
    end

    Timecop.return
  end
end