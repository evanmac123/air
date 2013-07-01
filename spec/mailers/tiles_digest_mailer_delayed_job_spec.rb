require "spec_helper"

include TileHelpers

describe 'Automatic weekly sending of tiles-digest email' do
  it 'qualifying demos should schedule a dj call to send out all emails' do
    demos = FactoryGirl.create_list :demo, 3
    Demo.stubs(:send_digest_email).returns(demos)

    # This is the method that gets called daily from a cron job
    TilesDigestMailer.notify_all_from_delayed_job

    Delayed::Job.all.each_with_index do |dj_record, i|
      dj_record.run_at.should == Date.today.midnight.advance(hours: 12)

      dj_record.handler.should include 'TilesDigestMailer'
      dj_record.handler.should include ':notify_all'
      dj_record.handler.should include demos[i].id.to_s
    end
  end

  it "the automatic sending of a digest email can be overridden by changing the 'Send On' day" do
    demos = FactoryGirl.create_list :demo, 3, tile_digest_email_send_on: 'Tuesday'

    # Tiles only get sent out if there are users to see them => better create some
    user_demo_0 = FactoryGirl.create :user, demo: demos[0]
    user_demo_1 = FactoryGirl.create :user, demo: demos[1]
    user_demo_2 = FactoryGirl.create :user, demo: demos[2]

    # '7/1/2013' is on a Monday
    send_it               = create_tile on_day: '7/1/2013', demo: demos[0]
    no_send_different_day = create_tile on_day: '7/1/2013', demo: demos[1]
    no_send_never         = create_tile on_day: '7/1/2013', demo: demos[2]

    on_day('7/2/2013') do
      # This is the method that gets called daily from a cron job
      TilesDigestMailer.notify_all_from_delayed_job

      demos[1].update_attributes tile_digest_email_send_on: 'Sunday'
      demos[2].update_attributes tile_digest_email_send_on: 'Never'

      # Only this digest email (i.e. for this demo, for this user, with this tile) should only get added to the dj queue.
      # That's the first call to this method. The second is when it actually gets processed by the dj worker.
      TilesDigestMailer.expects(:notify_one).twice.with(demos[0].id, user_demo_0.id, [send_it.id])

      Timecop.travel Time.now + 12.hours
      crank_dj_clear
    end
  end
end
