require 'spec_helper'

describe Report::Activity do
  let!(:demo) { FactoryGirl.create :demo, id: 1, name: 'RobertJohnsonDemo' }

  describe '#new' do
    it 'creates a valid object if associated demo exists' do
      lambda { Report::Activity.new(1) }.should_not raise_error
    end

    it 'raises an exception if associated demo does not exist' do
      lambda { Report::Activity.new(2) }.should raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe '#send_email' do
    let(:act_report) { Report::Activity.new(1) }

    before(:each) do
      Demo.stubs(:find).returns(demo)
      act_report.stubs(:csv_data).returns('xxx')
    end

    #addresses.split(/,/).each { |address| Mailer.activity_report(csv_data, demo.name, Time.now, address).deliver }

    it 'sends an email to one address' do
      Mailer.stubs(:activity_report)
      #Mail::Message.any_instance.stubs(:deliver).returns(true)
      act_report.send_email 'robert@johnson.com'
      Mailer.should have_received(:activity_report).once
      #Mailer.should have_received(:activity_report).with(instance_of(String), instance_of(String), instance_of(Time), 'robert@johnson.com')
    end

    it 'sends an email to multiple addresses (separated by commas)' do
      act_report.send_email 'robert@johnson.com,keb@mo.com,eric@clapton.com'
    end
  end

  before(:each) do

#todo will need to create different locations for demos

    @demo = FactoryGirl.create :demo, :name => "Tiny Sparrow"

    @user1 = FactoryGirl.create :user, :name => "Bob Smith", :demo => @demo
    @user2 = FactoryGirl.create :user, :name => "Ann Jones", :demo => @demo

    @rule1 = FactoryGirl.create :rule, :demo_id => @demo.id
    @rule2 = FactoryGirl.create :rule, :demo_id => nil

    FactoryGirl.create :primary_value, :value => 'ate kitten', :rule => @rule1
    FactoryGirl.create :primary_value, :value => 'ate sausage', :rule => @rule2

    FactoryGirl.create :act, :created_at => "2011-05-01 12:30", :user => @user1, :rule => @rule1, :demo_id => @demo.id
    FactoryGirl.create :act, :created_at => "2011-05-01 12:00", :user => @user2, :rule => @rule2, :demo_id => @demo.id
    FactoryGirl.create :act, :created_at => "2011-05-01 11:15", :user => @user2, :text => 'joined the game', :demo_id => @demo.id
    FactoryGirl.create :act, :created_at => "2011-05-01 11:00", :user => @user1, :text => 'joined the game', :demo_id => @demo.id
  end

  shared_examples_for "a valid instantiation" do
    describe "#report_csv" do
      it "should return what we expect" do
        expected_csv = <<-END_CSV
2011-05-01,11,00,00,Bob Smith,joined the game
2011-05-01,11,15,00,Ann Jones,joined the game
2011-05-01,12,00,00,Ann Jones,ate sausage
2011-05-01,12,30,00,Bob Smith,ate kitten
        END_CSV

        @report.report_csv.should == expected_csv
      end
    end
  end

  context "when the company is identified by name" do
    before(:each) do
      @report = Report::Activity.new(@demo.name)
    end

    it_should_behave_like "a valid instantiation"
  end

  context "when the company is identified by ID" do
    before(:each) do
      @report = Report::Activity.new(@demo.id)
    end

    it_should_behave_like "a valid instantiation"
  end

  context "when no valid company is identified" do
    it "should raise an exception" do
      bad_id = Demo.order("id ASC").last.id + 1
      Demo.where(:id => bad_id).should be_empty

      lambda{Report::Activity.new(bad_id)}.should raise_exception(ArgumentError)
    end
  end

  describe "#email_to" do
    before(:each) do
      Timecop.freeze(Time.parse("2011-05-01 13:00:00 EDT"))

      @report = Report::Activity.new(@demo.id)
      @report.stubs(:report_csv).returns("fake CSV data")

      @mail = stub('mail object', :deliver => true)
      Mailer.stubs(:activity_report).with('fake CSV data', @demo.name, kind_of(Time), kind_of(String)).returns(@mail)
    end

    after(:each) do
      Timecop.return
    end

    context "when passed a single address" do
      it "should send a CSV file there" do
        @report.send_email("vlad@example.com")
        crank_dj_clear

        Mailer.should have_received(:activity_report).with('fake CSV data', @demo.name, Time.now, 'vlad@example.com')
        @mail.should have_received(:deliver)
      end
    end
    
    context "when passed comma-separated addresses" do
      it "should send a CSV file to each" do
        @report.send_email("vlad@example.com,phil@example.com")
        crank_dj_clear

        Mailer.should have_received(:activity_report).with('fake CSV data', @demo.name, Time.now, 'vlad@example.com')
        Mailer.should have_received(:activity_report).with('fake CSV data', @demo.name, Time.now, 'phil@example.com')
        @mail.should have_received(:deliver).twice
      end
    end
  end
end
