require 'spec_helper'

describe ScheduleDigestAndFollowUp do
  it "schedules digest and follow up" do
    TrackEvent.stubs(:ping)
    TilesDigestMailer.stubs(:notify_all)
    FollowUpDigestEmail.stubs(:create)

    instance = ScheduleDigestAndFollowUp.new(params)

    expect(instance.demo.unclaimed_users_also_get_digest).to eq(true)
    expect(instance.demo.tile_digest_email_sent_at).to eq(nil)

    instance.schedule!

    expect(instance.demo.unclaimed_users_also_get_digest).to eq(false)
    expect(instance.demo.tile_digest_email_sent_at).to_not eq(nil)

    # FIXME: This test is new, but we are skipping the following assertions until we convert to using rspec's mocking library instead of Mocha.  This avoids have to add the Bourne gem to allow for Spies with Mocha, which we'll need to fully test this object. Once we have spies, we should test all the nuances in ScheduleDigestAndFollowUp.schedule_digest_sent_ping which will cover all the previous test cases we had in the acceptance tests.
    # expect(TrackEvent).to have_recieved(:ping)
    # expect(TilesDigestMailer).to have_recieved(:notify_all)
    # expect(FollowUpDigestEmail).to have_recieved(:create)
  end

  def params
    {
      demo: FactoryGirl.create(:demo),
      unclaimed_users_also_get_digest: false,
      custom_headline: "Custom Headline",
      custom_message: "Custom Message",
      custom_subject: "Custom Subject",
      alt_custom_subject: "alt_custom_subject",
      follow_up_day: "Friday",
      current_user: FactoryGirl.create(:client_admin)
    }
  end
end
