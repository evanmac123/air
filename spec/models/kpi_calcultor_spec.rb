require "spec_helper"

describe FinancialsKpiPresenter do
  before do 
    Timecop.freeze(Date.new(2015,11,8))
    setup_test_data
    Organization.stubs(:all).returns(@orgs)
    @today = Date.today
    @sdate = 1.week.ago.to_date
    @edate = 1.week.from_now.to_date
  end

  after do
    Timecop.return
  end

  it "has test data " do
    expect(@data.keys.count).to eq 30
    expect(@orgs.count).to eq 30
  end

  it "test data " do
    expect(Organization.all).to eq @orgs 
  end

  it "has is correct active" do
    expect(Organization.active_during_period(@sdate, @edate).count).to eq 27
  end

  it "has is correct added " do
    expect(Organization.added_during_period(@sdate, @edate).count).to eq 0
  end

  it "has is correct possible churn " do
    expect(Organization.possible_churn_during_period(@sdate, @edate).count).to eq 0 
  end




  def setup_test_data
    @data ={
      #active  15
      "client1"  =>  ["American Speech-Language-Hearing Association", "10/1/2013", "10/1/2016"],
      "client2"  =>  ["Natick Public Schools", "10/1/2013", "10/1/2016"],
      "client3"  =>  ["e+CancerCare", "3/1/2014", "3/1/2016"],
      "client4"  =>  ["The MENTOR Network", "3/1/2014", "3/1/2016"],
      "client6"  =>  ["American Society for Clinical Oncology", "9/1/2014", "3/1/2016"],
      "client7"  =>  ["Milton CAT", "9/30/2014", "9/30/2016"],
      "client16" =>  ["Merz", "4/1/2015", "8/15/2016"],
      "client17" =>  ["South Middlesex Regional Vocational Technical School District", "4/1/2015", "4/1/2016"],
      "client20" =>  ["ABH CT", "6/22/2015", "6/22/2016"],
      "client21" =>  ["Aronson LLC", "7/1/2015", "7/1/2016"],
      "client24" =>  ["Golden Living", "8/11/2015", "8/11/2016"],
      "client25" =>  ["Vernon College", "9/1/2015", "9/1/2016"],
      "client26" =>  ["Shout! Factory", "9/9/2015", "3/9/2016"],
      "client27" =>  ["Envision IT", "9/11/2015", "9/11/2016"],
      "client30" =>  ["Texas Health", "10/1/2015", "10/1/2016"],
      
     #close to churning 5
      "client15" =>  ["TIAA-CREF", "3/1/2015", "3/1/2016"],
      "client18" =>  ["Merchant Choice Payment Solutions", "4/9/2015", "4/9/2016"],
      "client23" =>  ["Alta Regional Medical Center", "8/8/2015", "3/8/2016"],
      "client28" =>  ["RLE Technologies", "9/18/2015", "2/18/2016"],
      "client29" =>  ["Access Sciences", "9/27/2015", "2/27/2016"],
      
      #churned
      "client5"  =>  ["Towers Watson, Boston Office", "6/30/2014", "6/29/2015"],
      "client8"  =>  ["Legg Mason", "11/1/2014", "1/31/2015"],
      "client9"  =>  ["Town of Dedham","12/1/2014", "12/1/2015"],
      "client10" =>  ["CNH Industrial", "1/1/2015", "1/1/2016"],
      "client11" =>  ["Everyday Health", "1/1/2015", "1/1/2016"],
      "client12" =>  ["Fujifilm", "1/1/2015", "1/1/2016"],
      "client13" =>  ["Kaiser Permenente", "1/1/2015", "1/1/2016"],
      "client14" =>  ["Houston Methodist", "2/1/2015", "2/1/2016"],
      "client19" =>  ["Madison Logic", "5/18/2015", "7/17/2015"],
      "client22" =>  ["UTC", "8/1/2015", "2/1/2016"],
    }

   @orgs = @data.map do |k, v|
     org = Organization.new
     org.stubs(:name).returns(v[0])
     org.stubs(:customer_start_date).returns(Date.strptime(v[1], "%m/%d/%Y"))
     org.stubs(:customer_end_date).returns(Date.strptime(v[2], "%m/%d/%Y"))
     org
   end
  end

end






