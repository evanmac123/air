require 'spec_helper'

describe Report::Activity do
  before(:each) do
    @demo = Factory :demo, :company_name => "Tiny Sparrow"

    @user1 = Factory :user, :name => "Bob Smith", :demo => @demo
    @user2 = Factory :user, :name => "Ann Jones", :demo => @demo

    @rule1 = Factory :rule, :demo_id => @demo.id
    @rule2 = Factory :rule, :demo_id => nil

    Factory :primary_value, :value => 'ate kitten', :rule => @rule1
    Factory :primary_value, :value => 'ate sausage', :rule => @rule2

    Factory :act, :created_at => "2011-05-01 12:30", :user => @user1, :rule => @rule1, :demo_id => @demo.id
    Factory :act, :created_at => "2011-05-01 12:00", :user => @user2, :rule => @rule2, :demo_id => @demo.id
    Factory :act, :created_at => "2011-05-01 11:15", :user => @user2, :text => 'joined the game', :demo_id => @demo.id
    Factory :act, :created_at => "2011-05-01 11:00", :user => @user1, :text => 'joined the game', :demo_id => @demo.id
  end

  shared_examples_for "a valid instantiation" do
    describe "#report_csv" do
      it "should return what we expect" do
        expected_csv = <<-END_CSV
2011-05-01,11:00:00 UTC,Bob Smith,joined the game
2011-05-01,11:15:00 UTC,Ann Jones,joined the game
2011-05-01,12:00:00 UTC,Ann Jones,ate sausage
2011-05-01,12:30:00 UTC,Bob Smith,ate kitten
        END_CSV

        @report.report_csv.should == expected_csv
      end
    end
  end

  context "when the company is identified by name" do
    before(:each) do
      @report = Report::Activity.new(@demo.company_name)
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
      bad_id = @demo.id + 1
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
      Mailer.stubs(:activity_report).with('fake CSV data', @demo.company_name, kind_of(Time), kind_of(String)).returns(@mail)
    end

    after(:each) do
      Timecop.return
    end

    context "when passed a single address" do
      it "should send a CSV file there" do
        @report.email_to("vlad@example.com")

        Mailer.should have_received(:activity_report).with('fake CSV data', @demo.company_name, Time.now, 'vlad@example.com')
        @mail.should have_received(:deliver)
      end
    end
    
    context "when passed comma-separated addresses" do
      it "should send a CSV file to each" do
        @report.email_to("vlad@example.com,phil@example.com")

        Mailer.should have_received(:activity_report).with('fake CSV data', @demo.company_name, Time.now, 'vlad@example.com')
        Mailer.should have_received(:activity_report).with('fake CSV data', @demo.company_name, Time.now, 'phil@example.com')
        @mail.should have_received(:deliver).twice
      end
    end
  end
end
