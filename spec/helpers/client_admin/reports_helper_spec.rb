require 'rails_helper'

describe ClientAdmin::ReportsHelper do
  before do
    @helper = Object.new.extend(ClientAdmin::ReportsHelper)
  end

  describe "#report_default_start_date" do
    it "returns demo_launch if launch date is less than 12 months ago" do
      launch_date = Time.now - 6.months
      helper.stubs(:demo_launch).returns(launch_date)

      expect(helper.report_default_start_date).to eq(launch_date)
    end

    it "returns 1.year.ago if demo_launch is greater than 12 months ago" do
      Timecop.freeze(Time.now)

      launch_date = Time.now - 5.years
      helper.stubs(:demo_launch).returns(launch_date)

      expect(helper.report_default_start_date).to eq(1.year.ago)
    end
  end

  describe "#demo_launch" do
    it "returns Demo.created_at" do
      Timecop.freeze(Time.now)
      demo = FactoryGirl.create(:demo)

      helper.stubs(:current_demo).returns(demo)

      expect(helper.send(:demo_launch)).to eq(demo.created_at)
    end
  end

  describe "#reportings_date_switch_opts" do
    it "returns an array of options with the correct formatted names for boards older that 5 years" do
      Timecop.freeze(Time.new(1990))
      demo = FactoryGirl.create(:demo, created_at: 7.years.ago)

      helper.stubs(:current_demo).returns(demo)

      result = ["Past 12 Months", "Past Five Years", "1989", "1988", "1987", "1986"]

      expectation = helper.reportings_date_switch_opts.map { |opt| opt[:formatted_name] }

      expect(expectation).to eq(result)
    end

    it "returns an arry of options with the correct formatted names for boards older than 1 year" do
      Timecop.freeze(Time.new(1990))
      demo = FactoryGirl.create(:demo, created_at: 400.days.ago)

      helper.stubs(:current_demo).returns(demo)

      result = ["Past 12 Months", "All Time", "1989", "1988"]

      expectation = helper.reportings_date_switch_opts.map { |opt| opt[:formatted_name] }

      expect(expectation).to eq(result)
    end

    it "returns an arry of options with the correct formatted names for boards less than 1 year old" do
      Timecop.freeze(Time.new(1990))
      demo = FactoryGirl.create(:demo, created_at: 6.months.ago)

      helper.stubs(:current_demo).returns(demo)

      result = ["All Time", "1989"]

      expectation = helper.reportings_date_switch_opts.map { |opt| opt[:formatted_name] }

      expect(expectation).to eq(result)
    end

    describe "#past_twelve_months" do
      it "returns opts hash to activate reports for last 12 months" do
        Timecop.freeze(Time.new(1990))
        demo = FactoryGirl.create(:demo, created_at: 7.years.ago)

        helper.stubs(:current_demo).returns(demo)

        result = {
          formatted_name: "Past 12 Months",
          start_active: true,
          start_date: Time.now - 1.year,
          end_date: Time.now,
        }

        expect(helper.send(:past_twelve_months)).to eq(result)
      end

      it "returns nil if demo launched less than a year ago" do
        Timecop.freeze(Time.new(1990))
        demo = FactoryGirl.create(:demo, created_at: 6.months.ago)

        helper.stubs(:current_demo).returns(demo)

        expect(helper.send(:past_twelve_months)).to eq(nil)
      end
    end

    describe "#five_years_or_older" do
      it "returns true if demo_launch is older than 5 years" do
        Timecop.freeze(Time.new(1990))
        demo = FactoryGirl.create(:demo, created_at: 1825.days.ago - 1.second)

        helper.stubs(:current_demo).returns(demo)

        expect(helper.send(:five_years_or_older?)).to eq(true)
      end

      it "returns false if demo_launch is not older than five years" do
        Timecop.freeze(Time.new(1990))
        demo = FactoryGirl.create(:demo, created_at: 1825.days.ago + 1.second)

        helper.stubs(:current_demo).returns(demo)

        expect(helper.send(:five_years_or_older?)).to eq(false)
      end
    end
  end
end
