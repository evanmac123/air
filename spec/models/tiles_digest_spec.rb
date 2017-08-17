require 'rails_helper'

RSpec.describe TilesDigest, :type => :model do
  def digest_params(demo, current_user, users_bool)
    {
      demo: demo,
      sender: current_user,
      include_unclaimed_users: users_bool,
      headline: "Headline",
      message: "Message",
      subject: "Subject",
      alt_subject: "Alt Subject",
    }
  end

  let(:client_admin) { FactoryGirl.create(:client_admin) }
  let(:demo) { client_admin.demo }

  describe "#after_destroy" do
    describe "#destroy_from_redis" do
      it "removes all associated redis keys" do
        digest = TilesDigest.create(demo: demo, subject: "Subject A", alt_subject: "Subject B")
        digest_id = digest.id

        digest.rdb[:key].set(1)
        digest.rdb[:key][:subkey].incr

        expect(TilesDigest.rdb[digest_id][:key].get).to eq("1")
        expect(TilesDigest.rdb[digest_id][:key][:subkey].get).to eq("1")

        digest.destroy

        expect(TilesDigest.rdb[digest_id][:key].get).to eq(nil)
        expect(TilesDigest.rdb[digest_id][:key][:subkey].get).to eq(nil)
      end
    end
  end

  describe "#self.deliver" do

    let(:tiles_digest) { TilesDigest.dispatch(digest_params(demo, client_admin, true)) }

    it "calls #send_emails" do
      TilesDigest.any_instance.stubs(:schedule_followup)
      TilesDigest.any_instance.stubs(:set_tile_email_report_notifications)

      TilesDigest.any_instance.expects(:send_emails).once

      tiles_digest.deliver(5)
    end

    it "calls #schedule_followup" do
      TilesDigest.any_instance.stubs(:send_emails)
      TilesDigest.any_instance.stubs(:set_tile_email_report_notifications)

      TilesDigest.any_instance.expects(:schedule_followup).with(5).once

      tiles_digest.deliver(5)
    end

    it "calls #set_tile_email_report_notifications" do
      TilesDigest.any_instance.stubs(:send_emails)
      TilesDigest.any_instance.stubs(:schedule_followup)

      TilesDigest.any_instance.expects(:set_tile_email_report_notifications).once

      tiles_digest.deliver(5)
    end
  end

  describe ".dispatch" do
    it "creates a tiles_digest object with correct attrs and tiles" do
      demo.update_attributes(tile_digest_email_sent_at: Time.now)
      params = digest_params(demo, client_admin, true)
      tiles = FactoryGirl.create_list(:tile, 5, demo: demo)
      digest = TilesDigest.dispatch(params)

      expect(digest.persisted?).to be true
      expect(digest.sender).to eq(client_admin)
      expect(digest.headline).to eq(params[:headline])
      expect(digest.message).to eq(params[:message])
      expect(digest.subject).to eq(params[:subject])
      expect(digest.alt_subject).to eq(params[:alt_subject])
      expect(digest.cutoff_time).to eq(demo.tile_digest_email_sent_at)
      expect(digest.tiles.pluck(:id).sort).to eq(tiles.map(&:id).sort)
    end
  end

  describe "#set_tile_email_report_notifications" do
    it "asks ClientAdmin::NotificationsManager to set_tile_email_report_notifications in the background" do
      Timecop.freeze(Time.local(1990))
      digest = TilesDigest.create(demo: demo)

      ClientAdmin::NotificationsManager.expects(:delay).with(run_at: 1.hour.from_now).returns(ClientAdmin::NotificationsManager)
      ClientAdmin::NotificationsManager.expects(:set_tile_email_report_notifications).with(board: digest.demo)


      digest.set_tile_email_report_notifications
      Timecop.return
    end
  end

  describe "#send_emails" do
    before do
      params = digest_params(demo, client_admin, true)
      _tiles = FactoryGirl.create_list(:tile, 5, demo: demo)
      _users = FactoryGirl.create_list(:user, 5, demo: demo)
      @digest = TilesDigest.dispatch(params)
    end

    it "calls notify_all on TilesDigestMailer" do
      TilesDigestMailer.stubs(:delay).returns(TilesDigestMailer)

      TilesDigestMailer.expects(:notify_all).with(@digest)

      @digest.send_emails
    end

    it "updates recipient_count to the demo.users count at the time excluding site admins" do
      @digest.send_emails
      expect(@digest.recipient_count).to eq(demo.users.count)
    end

    it "updates delivered to true" do
      @digest.send_emails
      expect(@digest.delivered).to be true
    end
  end

  describe "#schedule_followup" do
    before do
      params = digest_params(demo, client_admin, true)
      @digest = TilesDigest.dispatch(params)
    end

    it "does nothing if follow_up_days_idx is 0 (no follow up)" do
      expect(@digest.schedule_followup(0)).to be nil
    end

    it "calls creates a follow_up_digest_email" do
      expect(@digest.follow_up_digest_email.present?).to be false

      @digest.update_attributes(delivered: true)
      @digest.schedule_followup(1)

      expect(@digest.follow_up_digest_email.present?).to be true

      follow_up = @digest.follow_up_digest_email

      expect(follow_up.send_on).to eq(Date.today + 1)
      expect(follow_up.user_ids_to_deliver_to).to eq(@digest.send(:user_ids_to_deliver_to))
    end
  end

  describe "#tile_ids" do
    it "returns tile_ids from associated tiles" do
      tiles = FactoryGirl.create_list(:tile, 5, demo: demo)
      digest = TilesDigest.create(demo: demo, sender: client_admin)

      tiles.each do |tile|
        digest.tiles << tile
      end

      expect(digest.tile_ids.sort).to eq(tiles.map(&:id).sort)
    end
  end

  describe "#before_save" do
    it "calls :set_default_subject" do
      TilesDigest.any_instance.expects(:set_default_subject).once
      TilesDigest.create(demo: demo, sender: client_admin)
    end

    it "calls :sanitize_subject_lines" do
      TilesDigest.any_instance.expects(:sanitize_subject_lines).once
      TilesDigest.create(demo: demo, sender: client_admin)
    end
  end

  describe "#set_default_subject" do
    it "does nothing if subject is set" do
      digest = TilesDigest.new(subject: "Subject")
      digest.send(:set_default_subject)

      expect(digest.subject).to eq("Subject")
    end

    it "sets the subject to the default subject if subject is nil" do
      digest = TilesDigest.new
      digest.send(:set_default_subject)

      expect(digest.subject).to eq(TilesDigest::DEFAULT_DIGEST_SUBJECT)
    end
  end

  describe "#all_related_subject_lines" do
    describe "when no follow_up_digest_email" do
      it "returns subject, alt_subject" do
        digest = TilesDigest.new(subject: "Subject A", alt_subject: "Subject B")
        subjects = digest.all_related_subject_lines

        expect(subjects).to eq(["Subject A", "Subject B"])
      end
    end

    describe "when follow_up_digest_email" do
      it "returns subject, alt_subject and a decorated follow_up_digest_email subject" do
        digest = TilesDigest.create(demo: demo, subject: "Subject A", alt_subject: "Subject B")
        _follow_up = digest.create_follow_up_digest_email

        subjects = digest.all_related_subject_lines

        expect(subjects).to eq(["Subject A", "Subject B", "Don't Miss: Subject A", "Don't Miss: Subject B"])
      end
    end
  end

  describe "#increment_logins_by_subject_line" do
    it "increments login counts in a redis sorted set" do
      digest = TilesDigest.new
      expect(digest.rdb[:logins].zrangebyscore("-inf", "inf", "WITHSCORES")).to eq([])

      2.times do
        digest.increment_logins_by_subject_line("A")
      end

      3.times do
        digest.increment_logins_by_subject_line("B")
      end

      expect(digest.rdb[:logins].zrangebyscore("-inf", "inf", "WITHSCORES")).to eq(["A", "2", "B", "3", ])
    end
  end

  describe "#logins_by_subject_line" do
    it "returns an ordered array of highest login subject line to lowest login subject line" do
      digest = TilesDigest.new
      expect(digest.logins_by_subject_line).to eq([])

      2.times do
        digest.rdb[:logins].zincrby(1, "A")
      end

      3.times do
        digest.rdb[:logins].zincrby(1, "B")
      end

      expect(digest.logins_by_subject_line).to eq(["3", "B", "2", "A"])
    end
  end

  describe "#new_unique_login?" do
    it "returns true if a user id  is added to the unique_login_set" do
      digest = TilesDigest.new

      expect(digest.new_unique_login?(user_id: 1)).to eq(true)
      expect(digest.rdb[:unique_login_set].smembers).to eq(["1"])
    end

    it "returns false if a user id is already in the unique_login_set" do
      digest = TilesDigest.new

      expect(digest.new_unique_login?(user_id: 1)).to eq(true)
      expect(digest.rdb[:unique_login_set].smembers).to eq(["1"])

      expect(digest.new_unique_login?(user_id: 1)).to eq(false)
    end
  end

  describe "#increment_unique_logins_by_subject_line" do
    it "increments unique login counts in a redis sorted set" do
      digest = TilesDigest.new
      expect(digest.rdb[:unique_logins].zrangebyscore("-inf", "inf", "WITHSCORES")).to eq([])

      2.times do
        digest.increment_unique_logins_by_subject_line("A")
      end

      3.times do
        digest.increment_unique_logins_by_subject_line("B")
      end

      expect(digest.rdb[:unique_logins].zrangebyscore("-inf", "inf", "WITHSCORES")).to eq(["A", "2", "B", "3", ])
    end
  end

  describe "#unique_logins_by_subject_line" do
    it "returns an ordered array of highest unique login subject line to lowest unique login subject line" do
      digest = TilesDigest.new
      expect(digest.unique_logins_by_subject_line).to eq([])

      2.times do
        digest.rdb[:unique_logins].zincrby(1, "A")
      end

      3.times do
        digest.rdb[:unique_logins].zincrby(1, "B")
      end

      expect(digest.unique_logins_by_subject_line).to eq(["3", "B", "2", "A"])
    end
  end

  describe ".paid" do
    it "returns a collection of TilesDigests that came from paid boards" do
      paid_board = FactoryGirl.create(:demo, customer_status_cd: Demo.customer_statuses[:paid])
      _free_board = FactoryGirl.create(:demo, customer_status_cd: Demo.customer_statuses[:free])
      _trial_board = FactoryGirl.create(:demo, customer_status_cd: Demo.customer_statuses[:trial])

      Demo.scoped.each do |demo|
        demo.tiles_digests.create
      end

      expect(TilesDigest.paid.pluck(:id)).to eq(paid_board.tiles_digests.pluck(:id))
    end
  end
end
