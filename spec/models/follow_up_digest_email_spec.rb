
require 'spec_helper'

describe FollowUpDigestEmail do
  let(:demo) { FactoryGirl.create(:demo) }
  let(:tiles_digest) { TilesDigest.create(demo: demo, subject: "Subject A", alt_subject: "Subject B") }

  describe '#follow_up_days' do
    it "returns 0 when the specified day is 'Never'" do
      expect(FollowUpDigestEmail.follow_up_days('Never')).to eq(0)
    end

    it "returns the number of days the specified day occurs after the current day" do
      days = %w(Sunday Monday Tuesday Wednesday Thursday Friday Saturday)

      Timecop.freeze(Time.zone.local(2013, 11, 3))  # Sunday
      results = [7, 1, 2, 3, 4, 5, 6]
      days.each_with_index { |day, i| expect(FollowUpDigestEmail.follow_up_days(day)).to eq(results[i]) }

      Timecop.freeze(Time.zone.local(2013, 11, 6))  # Wednesday
      results = [4, 5, 6, 7, 1, 2, 3]
      days.each_with_index { |day, i| expect(FollowUpDigestEmail.follow_up_days(day)).to eq(results[i]) }

      Timecop.freeze(Time.zone.local(2013, 11, 9))  # Saturday
      results = [1, 2, 3, 4, 5, 6, 7]
      days.each_with_index { |day, i| expect(FollowUpDigestEmail.follow_up_days(day)).to eq(results[i]) }

      Timecop.return
    end
  end

  describe "#set_subject" do
    it "sets decoratd subjects based on the TilesDigest's highest_performing_subject_line" do
      follow_up = FollowUpDigestEmail.new(tiles_digest: tiles_digest)
      tiles_digest.expects(:highest_performing_subject_line).returns(tiles_digest.alt_subject)

      follow_up.set_subject

      expect(follow_up.subject).to eq(follow_up.decorated_subject(tiles_digest.alt_subject))
    end
  end

  describe "#decorated_subject" do
    it "adds Don't Miss: in front of passed int subject" do
      follow_up = FollowUpDigestEmail.new

      expect(follow_up.decorated_subject("HEY")).to eq("Don't Miss: HEY")
    end
  end

  describe "#subject_before_sent" do
    it "returns follow_up.subject if present" do
      follow_up = FollowUpDigestEmail.new(subject: "SUBJECT")

      expect(follow_up.subject_before_sent).to eq("SUBJECT")
    end

    it "returns a decorated tiles_digest.highest_performing_subject_line if follow_up.subject is not present" do
      follow_up = FollowUpDigestEmail.new(tiles_digest: tiles_digest)
      tiles_digest.expects(:highest_performing_subject_line).returns("WINNER")

      expect(follow_up.subject_before_sent).to eq("Don't Miss: WINNER")
    end
  end

  context "Sending follow emails" do
    before  do
      @demo = FactoryGirl.create(:demo)
      @sender = FactoryGirl.create(:client_admin, demo: @demo)
      @sender.board_memberships.first.update_attributes(followup_muted: true)

      @muted = FactoryGirl.create(:user, accepted_invitation_at: 1.month.ago, demo: @demo)

      bm = @muted.board_memberships.first
      bm.followup_muted = true
      bm.save

      @user1 = FactoryGirl.create(:user, accepted_invitation_at: 1.month.ago, demo: @demo)
      @user2 = FactoryGirl.create(:user, accepted_invitation_at: 1.month.ago, demo: @demo)
      @user3 = FactoryGirl.create(:user, accepted_invitation_at: 1.month.ago, demo: @demo)
      @user4 = FactoryGirl.create(:user, accepted_invitation_at: 1.month.ago, demo: @demo)
      @user5 = FactoryGirl.create(:user, accepted_invitation_at: 1.month.ago, demo: @demo)

      @user6 = FactoryGirl.create(:user, demo: @demo) #unclaimed


      @not_in_digest = FactoryGirl.create(:tile, :active, demo: @demo, )
      @tiles = FactoryGirl.create_list(:tile, 2, :active, demo: @demo, )

      FactoryGirl.create(:tile_completion, user: @user4, tile: @not_in_digest, created_at: 2.weeks.ago)

      FactoryGirl.create(:tile_completion, user: @user1, tile: @tiles[0], created_at: 2.weeks.ago)
      FactoryGirl.create(:tile_completion, user: @user2, tile: @tiles[0], created_at: 2.weeks.ago)
      FactoryGirl.create(:tile_completion, user: @user3, tile: @tiles[1], created_at: 2.weeks.ago)


      User.claimed.each do |user|
        user.current_board_membership.update_attributes(joined_board_at: Time.current)
      end
    end

    context "claimed" do
      before do
        digest = @demo.tiles_digests.create(sender: @sender, headline: "headline", tile_ids: @tiles.map(&:id), include_unclaimed_users: false, sent_at: Time.current)

        @fu = digest.build_follow_up_digest_email(
          send_on: 1.hour.from_now,
          subject: "SUBJECT"
        )

        @fu.save
      end

      describe "#recipients" do
        it "list only claimed non muted users" do
          expect(@fu.recipients.pluck(:id).sort).to match_array [@user4.id, @user5.id].sort
        end
      end
    end

    context "All users" do
      before do
        digest = @demo.tiles_digests.create(sender: @sender, headline: "headline", tiles: @tiles, include_unclaimed_users: true, sent_at: Time.current)

        @fu = digest.build_follow_up_digest_email(
          send_on: 1.hour.from_now,
          subject: "SUBJECT"
        )

        @fu.save
      end

      describe "#recipients" do
        it "mails all non muted recipients" do
          expect(@fu.recipients.pluck(:id).sort).to match_array [@user4.id, @user5.id, @user6.id].sort
        end
      end

      describe "#recipient_ids" do
        it "returns arr of recipient_ids" do
          expect(@fu.recipient_ids.sort).to eq(@fu.recipients.pluck(:id).sort)
        end
      end

      describe "#trigger_deliveries" do
        it "mails all recipients with no tile completions for the current digest tiles" do
          TilesDigestMailer.stubs(:delay).returns TilesDigestMailer
          TilesDigestMailer.expects(:notify_one).at_most(5)
          @fu.trigger_deliveries
        end

        it "marks tiles_digest.followup_delivered as true" do
          TilesDigestMailer.stubs(:delay).returns TilesDigestMailer

          expect(@fu.tiles_digest.followup_delivered).to be false

          @fu.trigger_deliveries

          expect(@fu.tiles_digest.followup_delivered).to be true
        end
      end

      describe "#post_process_delivery" do
        it "sends ping and updates to sent state" do
          @fu.expects(:schedule_digest_sent_ping).once

          @fu.trigger_deliveries

          expect(@fu.sent).to be true
          expect(@fu.tiles_digest.followup_delivered).to be true
        end
      end
    end
  end

  def users_including_unclaimed include_unclaimed
    if include_unclaimed
      @demo.users.pluck(:id)
    else
      @demo.claimed_users.pluck(:id)
    end
  end
end
