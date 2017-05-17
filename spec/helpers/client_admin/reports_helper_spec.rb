require 'rails_helper'

describe ClientAdmin::ReportsHelper do
  before do
    @helper = Object.new.extend(ClientAdmin::ReportsHelper)
  end

  describe "#report_default_start_date" do
    it "returns demo_launch if launch date is less than 3 months ago" do
      launch_date = Time.zone.now - 2.months
      helper.stubs(:demo_launch).returns(launch_date)

      expect(helper.report_default_start_date).to eq(launch_date)
    end

    it "returns Time.now.end_of_month - 3.months if demo_launch is greater than 12 months ago" do
      Timecop.freeze(Time.zone.now)

      launch_date = Time.zone.now - 5.years
      helper.stubs(:demo_launch).returns(launch_date)

      expect(helper.report_default_start_date).to eq(Time.now.end_of_month - 3.months)
    end
  end

  describe "#demo_launch" do
    before do
      Timecop.freeze(Time.local(2010, 2, 15))
    end

    after do
      Timecop.return
    end

    it "returns Demo.launch_date.beginning_of_year" do
      demo = FactoryGirl.create(:demo)
      demo.created_at = Time.now - 1.year
      demo.launch_date = Time.now
      demo.save


      helper.stubs(:current_demo).returns(demo)

      expect(helper.send(:demo_launch)).to eq(demo.launch_date.beginning_of_year)
    end

    it "returns Demo.created_at.beginning_of_year if launch_date is not present" do
      demo = FactoryGirl.create(:demo)
      demo.created_at = Time.now - 1.year
      demo.launch_date = nil
      demo.save

      helper.stubs(:current_demo).returns(demo)

      expect(helper.send(:demo_launch)).to eq(demo.created_at.beginning_of_year)
    end
  end

  describe "#reportings_date_switch_opts" do
    before do
      Timecop.freeze(Time.new(1990))
    end

    after do
      Timecop.return
    end

    it "returns an array of options with the correct formatted names for boards older that 5 years" do
      demo = FactoryGirl.create(:demo, created_at: 7.years.ago)

      helper.stubs(:current_demo).returns(demo)

      result = ["Past 3 Months", "Past 12 Months", "Past Five Years", "1990", "1989", "1988", "1987"]

      expectation = helper.reportings_date_switch_opts.map { |opt| opt[:formatted_name] }

      expect(expectation).to eq(result)
    end

    it "returns an arry of options with the correct formatted names for boards older than 1 year" do
      demo = FactoryGirl.create(:demo, created_at: 400.days.ago)

      helper.stubs(:current_demo).returns(demo)

      result = ["Past 3 Months", "Past 12 Months", "All Time", "1990", "1989", "1988"]

      expectation = helper.reportings_date_switch_opts.map { |opt| opt[:formatted_name] }

      expect(expectation).to eq(result)
    end

    describe "#five_years_or_older" do
      it "returns true if demo_launch is older than 5 years" do
        demo = FactoryGirl.create(:demo, created_at: 1825.days.ago - 1.day)

        helper.stubs(:current_demo).returns(demo)

        expect(helper.send(:five_years_or_older?)).to eq(true)
      end

      it "returns false if demo_launch is not older than five years" do
        demo = FactoryGirl.create(:demo, created_at: 1825.days.ago + 1.year)

        helper.stubs(:current_demo).returns(demo)

        expect(helper.send(:five_years_or_older?)).to eq(false)
      end
    end
  end
end
