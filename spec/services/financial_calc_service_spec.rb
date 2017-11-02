require 'spec_helper'

describe FinancialsCalcService do

  before do

    Timecop.freeze(Date.current)
      org1 = FactoryGirl.create(:organization)
      org2 = FactoryGirl.create(:organization)
      org3 = FactoryGirl.create(:organization)
      org4 = FactoryGirl.create(:organization)
      org5 = FactoryGirl.create(:organization)
      FactoryGirl.create(:contract, :complete, :active, organization: org1, date_booked: Date.current, start_date: 1.week.from_now, end_date: 53.weeks.from_now)

      org2_con1 = FactoryGirl.create(:contract, :complete, :active, organization: org2, start_date: 3.months.ago, end_date: 9.months.from_now)
      #upgrade
      FactoryGirl.create(:contract, :complete, :active, organization: org2, parent_contract_id: org2_con1.id, amt_booked: 75, date_booked: 2.days.from_now , mrr: 75, cycle: Contract::MONTHLY, start_date: 2.days.from_now, end_date: 32.days.from_now)

      FactoryGirl.create(:contract, :complete, :active, organization: org3, amt_booked: 100, date_booked: 3.months.ago, mrr: 100, arr: 1200, cycle: Contract::MONTHLY, start_date: 2.months.ago, end_date: 1.month.from_now)
      FactoryGirl.create(:contract, :complete, :active, organization: org4, amt_booked: 100, date_booked: Date.tomorrow, mrr: 100, cycle: Contract::MONTHLY, start_date: 1.months.from_now, end_date: 2.months.from_now)

      @calc =FinancialsCalcService.new(Date.current, 1.week.from_now.to_date)
      yesterday = Date.yesterday
      year_ago_yesterday = yesterday.advance({years: -1})
      FactoryGirl.create(:contract, :complete, organization: org5, amt_booked: 2400, arr: 2400, date_booked: year_ago_yesterday, start_date: year_ago_yesterday, end_date: yesterday)
      FactoryGirl.create(:contract, :complete, organization: org5, amt_booked: 2400, arr: 2400, date_booked: Date.current, start_date: Date.current, end_date: 1.year.from_now)
    end

    after do
      Timecop.return
    end

    describe "#starting_customer_count" do
      it "behaves correctly" do
        expect(@calc.starting_customer_count).to eq(3)
      end
    end

    describe "#current_customer_count" do
      it "behaves correctly" do
        expect(@calc.current_customer_count).to eq(4)
      end
    end
    describe "#added_customer_count" do
      it "behaves correctly" do
        expect(@calc.added_customer_count).to eq(1)
      end
    end
    describe "#added_customer_amt_booked" do
      it "behaves correctly" do
        expect(@calc.added_customer_amt_booked).to eq(60100)
      end
    end

    describe "#upgrade_amt_booked" do
      it "behaves correctly" do
        expect(@calc.upgrade_amt_booked).to eq(75)
      end
    end

    describe "#renewal_amt_booked" do
      it "behaves correctly" do
        expect(@calc.renewal_amt_booked).to eq(2400)
      end
    end

  end
