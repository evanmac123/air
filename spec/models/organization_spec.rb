require 'spec_helper'

describe Organization do
  it "is valid when complete" do
    o = FactoryGirl.build(:organization, :complete)
    expect(o.valid?).to be_true
  end

  context "created org" do

    let(:org){FactoryGirl.create(:organization, :with_contracts)}

    describe "customer_start_date" do

      it "has start_date equal to earliest contract start date" do
        expect(org.customer_start_date.to_s).to eq("2012-01-01")
      end

      it "has start_date equal to earliest contract start date" do
        expect(org.customer_end_date.to_s).to eq("2014-12-31")
      end

    end

    describe "active" do
      it "is true if customer_end_date is greater than today" do
        new_today = Date.parse('2014-10-30')
        Timecop.freeze(new_today) do
          expect(org.active).to  be_true
        end
      end

      it "is
      false if customer_end_date is greater than today" do
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


    describe ".active_by_date" do
      before do 
        @client = FactoryGirl.create(:organization, :complete, :with_active_contract)
        @client2 = FactoryGirl.create(:organization, :complete, :with_active_contract)
        @client3 = FactoryGirl.create(:organization, :complete)
      end

      it "excludes inactive clients" do
        expect(Organization.active_by_date(Date.today).count).to eq 2
      end
    end

    describe ".possible_churn" do
      before do 
        @client = FactoryGirl.create(:organization, :complete)
      end

      it "excludes inactive clients" do
        FactoryGirl.create(:contract, :complete, start_date: 1.year.ago, end_date: 1.week.from_now, organization: @client)
        FactoryGirl.create(:contract, :complete, start_date: 1.year.ago, end_date: 2.weeks.ago, organization: @client)
        binding.pry
        expect(Organization.possible_churn(1.week.ago, Date.today).count).to eq 1
      end
    end


  end
end
