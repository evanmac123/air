require 'rails_helper'

RSpec.describe TilesDigestAutomator, type: :model, delay_jobs: true do
  it { should belong_to(:demo) }
  it { should validate_presence_of(:demo) }
  it { should validate_presence_of(:day) }
  it { should validate_presence_of(:time) }
  it { should validate_presence_of(:frequency_cd) }
  it { should validate_presence_of(:deliver_date) }

  describe "#set_deliver_date" do
    it "sets deliver_date equal to the result of #next_deliver_time with the current_deliver_date as the origin" do
      demo = FactoryGirl.create(:demo)
      automator = demo.build_tiles_digest_automator

      deliver_date = Time.zone.local(1990)

      automator.expects(:next_deliver_time).returns(deliver_date)
      automator.set_deliver_date

      expect(automator.deliver_date).to eq(deliver_date)
    end
  end

  describe "#update_deliver_date" do
    it "calls #set_deliver_date and saves" do
      automator = TilesDigestAutomator.new

      automator.expects(:set_deliver_date)
      automator.expects(:save)

      automator.update_deliver_date
    end
  end

  describe "#schedule_delivery" do
    it "schedules a new delivery job" do
      demo = FactoryGirl.create(:demo)
      automator = demo.build_tiles_digest_automator
      automator.update_deliver_date

      automator.expects(:remove_job)

      automator.schedule_delivery

      expect(automator.job.present?).to eq(true)
      expect(automator.job.run_at).to eq(automator.deliver_date)
      expect(automator.job.queue).to eq("TilesDigestAutomation")
    end

    it "schedules #deliver for the delivery job" do
      demo = FactoryGirl.create(:demo)
      automator = demo.build_tiles_digest_automator
      automator.update_deliver_date

      automator.expects(:delay).with(run_at: automator.deliver_date, queue: "TilesDigestAutomation").returns(automator)
      automator.expects(:deliver).returns(OpenStruct.new({ id: "fake_job_id" }))
      automator.expects(:update_attributes).with(job_id: "fake_job_id")

      automator.schedule_delivery
    end
  end

  describe "#deliver" do
    it "calls #deliver_digest, #update_deliver_date, and #schedule_delivery" do
      automator = TilesDigestAutomator.new

      automator.expects(:deliver_digest)
      automator.expects(:update_deliver_date)
      automator.expects(:schedule_delivery)

      automator.deliver
    end
  end

  describe "#remove_job" do
    it "removes scheduled job" do
      demo = FactoryGirl.create(:demo)
      automator = demo.build_tiles_digest_automator
      automator.update_deliver_date
      automator.schedule_delivery

      expect(automator.job.present?).to eq(true)

      automator.remove_job

      expect(automator.job.present?).to eq(false)
    end

    it "returns nil if no job is present" do
      automator = TilesDigestAutomator.new

      expect(automator.remove_job).to eq(nil)
    end

    it "gets called before destroy" do
      demo = FactoryGirl.create(:demo)
      automator = demo.build_tiles_digest_automator
      automator.update_deliver_date

      automator.expects(:remove_job)

      automator.destroy
    end
  end

  describe "#job" do
    it "returns related job" do
      demo = FactoryGirl.create(:demo)
      automator = demo.build_tiles_digest_automator
      automator.update_deliver_date
      automator.schedule_delivery

      expect(automator.job).to eq(Delayed::Job.where(id: automator.job_id).first)
    end

    it "returns nil if no related job" do
      automator = TilesDigestAutomator.new

      expect(automator.job).to eq(nil)
    end
  end

  describe "#deliver_digest" do
    it "returns nil if its demo has no digest_tiles" do
      demo = FactoryGirl.create(:demo)
      automator = demo.build_tiles_digest_automator
      automator.update_deliver_date

      expect(demo.digest_tiles.present?).to eq(false)
      expect(automator.deliver_digest).to eq(nil)
    end

    it "asks TilesDigestForm to deliver a digest if there are digest tiles" do
      demo = FactoryGirl.create(:demo)
      automator = demo.build_tiles_digest_automator
      automator.update_deliver_date

      fake_tiles_digest_form = OpenStruct.new({ submit_schedule_digest_and_followup: true })

      Demo.any_instance.expects(:digest_tiles).returns(true)
      automator.expects(:tiles_digest_params).returns("fake_params")
      TilesDigestForm.expects(:new).with(demo: demo, params: "fake_params").returns(fake_tiles_digest_form)
      fake_tiles_digest_form.expects(:submit_schedule_digest_and_followup)

      automator.deliver_digest
    end
  end

  describe "#current_deliver_date" do
    context "when deliver_date is set" do
      it "returns #deliver_date" do
        automator = TilesDigestAutomator.new(deliver_date: Time.zone.local(1990))

        expect(automator.current_deliver_date).to eq(Time.zone.local(1990))
      end
    end

    context "when deliver_date is not set, but demo.tile_digest_email_sent_at is set" do
      it "returns demo.tile_digest_email_sent_at" do
        demo = FactoryGirl.create(:demo, tile_digest_email_sent_at: Time.zone.local(1990))
        automator = demo.build_tiles_digest_automator

        expect(automator.current_deliver_date).to eq(Time.zone.local(1990))
      end
    end

    context "when when neither deliver_date nor demo.tile_digest_email_sent_at is set" do
      it "returns Time.current" do
        demo = FactoryGirl.create(:demo)
        automator = demo.build_tiles_digest_automator

        Time.expects(:current)

        automator.current_deliver_date
      end
    end
  end

  describe "#next_deliver_time" do
    before do
      Timecop.freeze(Time.local(1990))
      demo = FactoryGirl.create(:demo)
      @automator = demo.build_tiles_digest_automator
      @automator.update_deliver_date
    end

    after do
      Timecop.return
    end

    context "when frequency is daily" do
      before do
        @automator.update_attributes(frequency_cd: TilesDigestAutomator.frequencies[:daily])
      end

      it "returns the next deliver_date" do
        expect(@automator.next_deliver_time).to eq(@automator.deliver_date + 1.day)
      end
    end

    context "when frequency is weekly" do
      before do
        @automator.update_attributes(frequency_cd: TilesDigestAutomator.frequencies[:weekly])
      end

      it "returns the next deliver_date" do
        expect(@automator.next_deliver_time).to eq(@automator.deliver_date + 1.week)
      end
    end

    context "when frequency is biweekly" do
      before do
        @automator.update_attributes(frequency_cd: TilesDigestAutomator.frequencies[:biweekly])
      end

      it "returns the next deliver_date" do
        expect(@automator.next_deliver_time).to eq(@automator.deliver_date + 2.weeks)
      end
    end

    context "when frequency is monthly" do
      before do
        @automator.update_attributes(frequency_cd: TilesDigestAutomator.frequencies[:monthly])
      end

      it "returns the next deliver_date" do
        date = (@automator.deliver_date + 1.month).beginning_of_month

        until date.wday == @automator.day
          date += 1.day
        end

        expect(@automator.next_deliver_time).to eq(date.change({ hour: @automator.time }))
      end
    end

    context "when a custom time is set" do
      it "accounts for the hour" do
        @automator.update_attributes(time: "22")

        expect(@automator.next_deliver_time).to eq((@automator.deliver_date + 1.week).change({ hour: "22" }))
      end
    end

    context "when custom day is set" do
      it "account for the day" do
        @automator.update_attributes(day: 4)

        expect(@automator.next_deliver_time.wday).to eq(4)
      end
    end
  end

  describe "#origin_for_reset" do
    before do
      Timecop.freeze(Time.local(1990))
      demo = FactoryGirl.create(:demo)
      @automator = demo.build_tiles_digest_automator
    end

    after do
      Timecop.return
    end

    describe "when frequency is weekly" do
      it "returns Time.current - 1.week" do
        @automator.weekly!
        expect(@automator.origin_for_reset).to eq(Time.current - 1.week)
      end
    end

    describe "when frequency is biweekly" do
      it "returns Time.current - 2.weeks" do
        @automator.biweekly!
        expect(@automator.origin_for_reset).to eq(Time.current - 2.weeks)
      end
    end

    describe "when frequency is daily" do
      it "returns Time.current" do
        @automator.daily!
        expect(@automator.origin_for_reset).to eq(Time.current)
      end
    end

    describe "when frequency is monthly" do
      it "returns Time.current" do
        @automator.monthly!
        expect(@automator.origin_for_reset).to eq(Time.current)
      end
    end
  end

  describe "#reset_deliver_date" do
    it "sets deliver day to the result of next_deliver_time(origin_for_reset)" do
      # This method prevents duplication of the next_deliver_time logic for weekly and biweekly automator updates. Without it, any update to these frequencies would skip the closest delivery date in favor of that date plus either 1 or 2 weeks. This way, we simply backtrack the time with origin_for_reset and use the same next_deliver_time method.

      automator = TilesDigestAutomator.new

      automator.expects(:origin_for_reset).returns("mock origin")
      automator.expects(:next_deliver_time).with("mock origin")

      automator.reset_deliver_date
    end
  end

  describe "#tiles_digest_params" do
    context "when there is a draft on the demo" do
      it "returns the draft" do
        demo = FactoryGirl.create(:demo)
        automator = demo.build_tiles_digest_automator
        automator.update_deliver_date

        automator.demo.expects(:get_tile_email_draft).returns("Fake Draft")

        expect(automator.send(:tiles_digest_params)).to eq("Fake Draft")
      end
    end

    context "when there is no draft on the demo" do
      it "returns the automator defaults" do
        demo = FactoryGirl.create(:demo)
        automator = demo.build_tiles_digest_automator({
          include_unclaimed_users: false,
          has_follow_up: false,
          include_sms: true
        })
        automator.update_deliver_date

        automator.demo.expects(:digest_tiles).returns([OpenStruct.new(headline: "CUSTOM SUBJECT!")])

        tiles_digest_params = {
          demo_id: demo.id,
          digest_send_to: false,
          follow_up_day: "Never",
          include_sms: true,
          custom_subject: "CUSTOM SUBJECT!"
        }

        expect(automator.send(:tiles_digest_params)).to eq(tiles_digest_params)
      end

      it "defaults follow_up_day to 3 days after delivery if has_follow_up" do
        demo = FactoryGirl.create(:demo)
        automator = demo.build_tiles_digest_automator({
          include_unclaimed_users: false,
          has_follow_up: true,
          include_sms: true,
          day: 1
        })
        automator.update_deliver_date

        automator.demo.expects(:digest_tiles).returns([OpenStruct.new(headline: "CUSTOM SUBJECT!")])

        tiles_digest_params = {
          demo_id: demo.id,
          digest_send_to: false,
          follow_up_day: "Thursday",
          include_sms: true,
          custom_subject: "CUSTOM SUBJECT!"
        }

        expect(automator.send(:tiles_digest_params)).to eq(tiles_digest_params)
      end

      it "does not send followup if frequency is daily regardless of has_follow_up" do
        demo = FactoryGirl.create(:demo)
        automator = demo.build_tiles_digest_automator({
          include_unclaimed_users: false,
          has_follow_up: true,
          frequency_cd: TilesDigestAutomator.frequencies[:daily],
          include_sms: true,
        })
        automator.update_deliver_date

        automator.demo.expects(:digest_tiles).returns([OpenStruct.new(headline: "CUSTOM SUBJECT!")])

        tiles_digest_params = {
          demo_id: demo.id,
          digest_send_to: false,
          follow_up_day: "Never",
          include_sms: true,
          custom_subject: "CUSTOM SUBJECT!"
        }

        expect(automator.send(:tiles_digest_params)).to eq(tiles_digest_params)
      end
    end
  end
end
