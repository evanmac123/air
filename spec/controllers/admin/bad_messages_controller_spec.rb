require 'spec_helper'

describe Admin::BadMessagesController do
  describe "#index" do
    describe "responding to an XHR with 'since' param" do
      before(:each) do
        Timecop.freeze('2010-05-01')

        @first_thread = Factory :bad_message_thread, :updated_at => Time.now - 5.years
        @second_thread = Factory :bad_message_thread, :updated_at => Time.now - 3.months
        @third_thread = Factory :bad_message_thread, :updated_at => Time.now - 3.days

        xhr :get, :index, :since => (Time.now - 3.years).to_s, :format => :json
        @parsed_response = JSON.parse(response.body)
      end

      after(:each) do
        Timecop.return
      end

      it "should report the most recent update time for any thread" do
        Time.parse(@parsed_response['last_updated_at']).should == @third_thread.updated_at
      end

      it "should have new HTML for just threads updated since the given time" do
        @parsed_response['updated_threads'].length.should == 2
        [@second_thread, @third_thread].each do |expected_thread|
          dom_id = "bad_message_thread_#{expected_thread.id}"
          @parsed_response['updated_threads'].any?{|html_chunk| html_chunk.include?(dom_id)}.should be_true 
        end
      end
    end
  end
end
