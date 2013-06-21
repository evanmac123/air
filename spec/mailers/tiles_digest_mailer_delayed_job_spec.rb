require "spec_helper"

describe 'whatever' do
  it 'should work' do
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
end
