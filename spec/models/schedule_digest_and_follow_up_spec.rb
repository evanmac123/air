require 'spec_helper'

describe ScheduleDigestAndFollowUp do
  it "schedules digest and follow up" do
    ScheduleDigestAndFollowUp.any_instance.stubs(:send_digest)
    TrackEvent.stubs(:ping)
    FollowUpDigestEmail.stubs(:create!)

    instance = ScheduleDigestAndFollowUp.new(params)

    expect(instance.demo.unclaimed_users_also_get_digest).to eq(true)
    expect(instance.demo.tile_digest_email_sent_at).to eq(nil)

    instance.schedule!

    expect(instance.demo.unclaimed_users_also_get_digest).to eq(false)
    expect(instance.demo.tile_digest_email_sent_at).to_not eq(nil)

    assert_received(TrackEvent, :ping) { |expect| expect.with('Digest - Sent', anything, anything) }
    assert_received(ScheduleDigestAndFollowUp.any_instance, :send_digest)
    assert_received(FollowUpDigestEmail, :create!)
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
