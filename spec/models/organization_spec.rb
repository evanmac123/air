require 'spec_helper'

describe Organization do
  it "is valid when complete" do
    o = FactoryGirl.build(:organization, :complete)
    expect(o.valid?).to be_true
  end

  context "customer start and and dates" do

    let(:org){FactoryGirl.create(:organization, :complete)}

    describe "customer_start_date" do

      it "has start_date equal to earliest contract start date" do
        first_start_date = 3.years.ago.to_date
        FactoryGirl.create(:contract, :complete, start_date: first_start_date, end_date: 5.days.ago, organization: org)
        FactoryGirl.create(:contract, :complete, start_date: 1.year.ago, end_date: 1.year.from_now, organization: org)
        expect(org.customer_start_date).to eq(first_start_date)
      end

      it "has end_date equal to earliest contract start date" do
        last_end_date = 9.months.from_now.to_date
        FactoryGirl.create(:contract, :complete, start_date: 1.year.ago, end_date: 5.days.ago, organization: org)
        FactoryGirl.create(:contract, :complete, start_date: 1.year.ago, end_date: last_end_date, organization: org)
        expect(org.customer_end_date).to eq(last_end_date)
      end

    end
  end

  context "customer active and lifetime" do

    let(:org){FactoryGirl.create(:organization, :complete, :with_contracts)}

    describe "active" do
      it "is true if customer_end_date is greater than today" do
        new_today = Date.parse('2014-10-30')
        Timecop.freeze(new_today) do
          expect(org.active).to  be_true
        end
      end

      it "is false if customer_end_date is greater than today" do
        new_today = Date.parse('2018-10-30')
        Timecop.freeze(new_today) do
          expect(org.active).to  be_false
        end
      end
    end

    describe "life_time" do
      it "equals totalmonths of contracts" do
        expect(org.life_time).to  eq 36 
      end
    end
  end

  describe ".active_by_date" do
    before do 
      @client = FactoryGirl.create(:organization, :complete, :with_active_contract)
      @client2 = FactoryGirl.create(:organization, :complete, :with_active_contract)
      @client3 = FactoryGirl.create(:organization, :complete)
    end

    it "excludes inactive clients" do
      expect(Organization.active_after_date(Date.today).all.count).to eq 2
    end
  end

  context "active and churned" do
    before do 
      @client = FactoryGirl.create(:organization, :complete)
      @client2 = FactoryGirl.create(:organization, :complete)
      @client3 = FactoryGirl.create(:organization, :complete)
    end

    describe ".possible_churn" do
      it "excludes churned clients" do
        FactoryGirl.create(:contract, :complete, start_date: 1.year.ago, end_date: 2.weeks.ago, organization: @client3)
        FactoryGirl.create(:contract, :complete, start_date: 1.year.ago, end_date: 3.days.from_now, organization: @client)
        FactoryGirl.create(:contract, :complete, start_date: 1.year.ago, end_date: 3.days.from_now, organization: @client)
        FactoryGirl.create(:contract, :complete, start_date: 1.year.ago, end_date: 2.weeks.from_now, organization: @client2)
        expect(Organization.possible_churn_during_period(Date.today.to_date, 1.week.from_now.to_date).size()).to eq 1
      end
    end

    describe ".added_during_period" do
      it "counts added clients for period" do
        FactoryGirl.create(:contract, :complete, start_date: 3.months.ago, end_date: 9.months.from_now, organization: @client)
        FactoryGirl.create(:contract, :complete, start_date: 1.year.ago, end_date: 2.weeks.from_now, organization: @client2)
        FactoryGirl.create(:contract, :complete, start_date: 1.week.ago, end_date: 55.weeks.from_now, organization: @client2)
        FactoryGirl.create(:contract, :complete, start_date: 5.days.ago, end_date: 55.weeks.from_now, organization: @client3)
        expect(Organization.added_during_period(1.week.ago.to_date, Date.today).size()).to eq 1
      end
    end

    describe ".churned_during_period" do
      it "counts churned clients for period" do
        #not churned
        FactoryGirl.create(:contract, :complete, start_date: 1.year.ago, end_date: 5.days.ago, organization: @client)
        FactoryGirl.create(:contract, :complete, start_date: 1.year.ago, end_date: 9.months.from_now, organization: @client)

        #just churned
        FactoryGirl.create(:contract, :complete, start_date: 1.year.ago, end_date: 2.months.ago, organization: @client2)
        FactoryGirl.create(:contract, :complete, start_date: 1.year.ago, end_date: 5.days.ago, organization: @client2)

        #churned prior to period

        FactoryGirl.create(:contract, :complete, start_date: 3.years.ago, end_date: 5.weeks.ago, organization: @client3)
        FactoryGirl.create(:contract, :complete, start_date: 5.months.ago, end_date: 55.weeks.ago, organization: @client3)
        expect(Organization.churned_during_period(1.week.ago.to_date, Date.today).size()).to eq 1
      end
    end

  end
end
