require 'rails_helper'

RSpec.describe TileEmailTrackerJob, type: :job do
  let (:user) { FactoryBot.create(:user) }
  let (:demo) { user.demo }
  let (:tile_email) { demo.tiles_digests.create }
  let (:email_type) { "tile_email" }
  let (:subject_line) { "Subject Line" }

  describe ".dispatch" do
    it "builds a new TileEmailTracker" do
      TileEmailTracker.stubs(:new).returns(stub_everything)

      TileEmailTrackerJob.perform_later(
        user: user,
        email_type: email_type,
        subject_line: subject_line,
        tile_email_id: tile_email.id,
        from_sms: false
      )

      expect(TileEmailTracker).to have_received(:new).with(
        user: user,
        email_type: email_type,
        subject_line: subject_line,
        tile_email_id: tile_email.id,
        from_sms: false
      )
    end

    it "calls track on a new TileEmailTracker" do
      TileEmailTracker.any_instance.stubs(:track)

      TileEmailTrackerJob.perform_later(
        user: user,
        email_type: email_type,
        subject_line: subject_line,
        tile_email_id: tile_email.id,
        from_sms: false
      )

      expect(TileEmailTracker.any_instance).to have_received(:track)
    end
  end
end
