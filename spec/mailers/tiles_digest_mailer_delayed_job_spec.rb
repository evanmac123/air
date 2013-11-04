require "spec_helper"

include TileHelpers

describe 'Follow-up email scheduled by delayed job' do

  def check_common_dj_attributes(dj_record)
    dj_record.run_at.should == Date.today.midnight.advance(hours: 12)

    dj_record.handler.should include 'TilesDigestMailer'
    dj_record.handler.should include ':notify_all_follow_up'
  end

  #----------------------------------------------------------------------------------

  it 'follow-up records get created with the correct content when appropriate' do
    demo_1 = FactoryGirl.create :demo
    FactoryGirl.create :user, demo: demo_1
    FactoryGirl.create_list :tile, 2, demo: demo_1

    demo_2 = FactoryGirl.create :demo
    FactoryGirl.create :user, demo: demo_2
    FactoryGirl.create_list :tile, 2, demo: demo_2

    #-----------------------------------------------------
    # 0 follow-up days signals that no follow-up email should be scheduled

    TilesDigestMailer.notify_all(demo_1, true, 0, demo_1.tile_digest_email_sent_at)
    FollowUpDigestEmail.count.should == 0

    TilesDigestMailer.notify_all(demo_2, false, 0, demo_2.tile_digest_email_sent_at)
    FollowUpDigestEmail.count.should == 0

    #-----------------------------------------------------
    # Test positive follow-up days for both cases of claimed vs. all users getting follow-ups

    TilesDigestMailer.notify_all(demo_1, true, 1, demo_1.tile_digest_email_sent_at)
    FollowUpDigestEmail.count.should == 1

    followup = FollowUpDigestEmail.first
    followup.demo_id.should == demo_1.id
    followup.tile_ids.sort.should == demo_1.tiles.pluck(:id).sort
    followup.send_on.should == Date.today + 1.day
    followup.unclaimed_users_also_get_digest.should be_true

    TilesDigestMailer.notify_all(demo_2, false, 4, demo_2.tile_digest_email_sent_at)
    FollowUpDigestEmail.count.should == 2

    followup = FollowUpDigestEmail.last
    followup.demo_id.should == demo_2.id
    followup.tile_ids.sort.should == demo_2.tiles.pluck(:id).sort
    followup.send_on.should == Date.today + 4.days
    followup.unclaimed_users_also_get_digest.should be_false
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

  it "should send the appropriate tiles the first time a digest is sent per demo too" do
    demo = FactoryGirl.create(:demo)
    demo.tile_digest_email_sent_at.should be_nil

    FactoryGirl.create :tile, headline: "Tile the first", status: Tile::ACTIVE, demo: demo
    FactoryGirl.create :tile, headline: "Tile the second", status: Tile::ACTIVE, demo: demo

    demo.active_tiles.should have(2).tiles

    FactoryGirl.create_list :user, 3, :claimed, demo: demo

    TilesDigestMailer.notify_all(demo, false, 4, demo.tile_digest_email_sent_at)
    crank_dj_clear

    ActionMailer::Base.deliveries.should have(3).emails
    ActionMailer::Base.deliveries.each do |mail|
      mail.to_s.should contain("Tile the first")
      mail.to_s.should contain("Tile the second")
    end
  end
end
