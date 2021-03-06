require 'spec_helper'

describe TileEmailTracker do
  let (:user) { FactoryBot.create(:user) }
  let (:demo) { user.demo }
  let (:tile_email) { demo.tiles_digests.create }
  let (:email_type) { "tile_email" }
  let (:subject_line) { "Subject Line" }

  describe "#track" do
    before do
      tile_email.update_attributes({
        subject: "Subject A",
        alt_subject: "Subject B"
      })

      tile_email.create_follow_up_digest_email
    end

    describe "when the subject line is invalid" do
      it "returns false" do
        invalid_subject = "Invalid"
        tile_email_tracker = TileEmailTracker.new(user: user, email_type: email_type, subject_line: invalid_subject, tile_email_id: tile_email.id, from_sms: false)

        expect(tile_email_tracker.track).to be(false)
      end
    end

    describe "when the user is a site_admin" do
      it "returns false" do
        site_admin = FactoryBot.create(:site_admin)
        tile_email_tracker = TileEmailTracker.new(user: site_admin, email_type: email_type, subject_line: tile_email.subject, tile_email_id: tile_email.id, from_sms: false)

        expect(tile_email_tracker.track).to be(false)
      end
    end

    describe "when the subject line is valid and the user is not site admin" do
      it "sends an email clicked ping with the right parameters" do
        tile_email_tracker = TileEmailTracker.new(user: user, email_type: email_type, subject_line: tile_email.subject, tile_email_id: tile_email.id, from_sms: false)

        tile_email_tracker.stubs(:ping)
        tile_email_tracker.track

        expect(tile_email_tracker).to have_received(:ping).with(
          "Email clicked",
          { email_type: email_type, subject_line: tile_email.subject, tiles_digest_id: tile_email.id, from_sms: false},
          user
        )
      end

      it "increments total email logins" do
        tile_email_tracker = TileEmailTracker.new(user: user, email_type: email_type, subject_line: tile_email.subject, tile_email_id: tile_email.id, from_sms: false)

        TilesDigest.any_instance.stubs(:increment_logins_by_subject_line)
        tile_email_tracker.track

        expect(TilesDigest.any_instance).to have_received(:increment_logins_by_subject_line).with(tile_email.subject)
      end

      it "increments unique email logins when the login is unique" do
        tile_email_tracker = TileEmailTracker.new(user: user, email_type: email_type, subject_line: tile_email.subject, tile_email_id: tile_email.id, from_sms: false)

        TilesDigest.any_instance.expects(:new_unique_login?).returns(true)
        TilesDigest.any_instance.expects(:increment_unique_logins_by_subject_line).with(tile_email_tracker.subject_line)

        tile_email_tracker.track
      end

      it "does not increment unique email logins when the login is not unique" do
        tile_email_tracker = TileEmailTracker.new(user: user, email_type: email_type, subject_line: tile_email.subject, tile_email_id: tile_email.id, from_sms: false)

        TilesDigest.any_instance.expects(:new_unique_login?).returns(false)
        TilesDigest.any_instance.expects(:increment_unique_logins_by_subject_line).with(tile_email_tracker.subject_line).never

        tile_email_tracker.track
      end
    end
  end

  describe "private" do
    before do
      tile_email.update_attributes({
        subject: "Subject A",
        alt_subject: "Subject B"
      })

      tile_email.create_follow_up_digest_email
    end

    describe "#valid_subject_line" do
      describe "when subject line is valid" do
        it "validates main subject" do
          subject = tile_email.subject

          tile_email_tracker = TileEmailTracker.new(user: user, email_type: email_type, subject_line: subject, tile_email_id: tile_email.id, from_sms: false)

          expect(tile_email_tracker.send(:valid_subject_line)).to eq(subject)
        end

        it "validates alt subject" do
          subject = tile_email.alt_subject

          tile_email_tracker = TileEmailTracker.new(user: user, email_type: email_type, subject_line: subject, tile_email_id: tile_email.id, from_sms: false)

          expect(tile_email_tracker.send(:valid_subject_line)).to eq(subject)
        end

        it "validates decorated follow up subject" do
          subject = tile_email.follow_up_digest_email.subject

          tile_email_tracker = TileEmailTracker.new(user: user, email_type: email_type, subject_line: subject, tile_email_id: tile_email.id, from_sms: false)

          expect(tile_email_tracker.send(:valid_subject_line)).to eq(subject)
        end
      end

      describe "when subject line is invalid" do
        it "returns nil" do
          subject = "INVALID"

          tile_email_tracker = TileEmailTracker.new(user: user, email_type: email_type, subject_line: subject, tile_email_id: tile_email.id, from_sms: false)

          expect(tile_email_tracker.send(:valid_subject_line)).to eq(nil)
        end
      end
    end
  end
end
