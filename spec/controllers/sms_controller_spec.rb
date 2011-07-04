require 'spec_helper'

# Hack to allow us to use regular controller tests to test SmsController 
# (which is an ActionController::Metal).
class SmsController
  include ActionController::UrlFor
  include ActionController::Testing
  include Rails.application.routes.url_helpers
  include ActionController::Compatibility
end

describe SmsController do
  describe "#create" do
    before(:each) do
      # We don't use hardly any of these fields, but this is what Twilio 
      # sends.

      @params = {
        'From'          => '+14152613077', 
        'Body'          => 'ate kitten', 
        'SmsSid'        => 'SM12ac8c0c64e01188d32fa2d4b40f1b5d',
        'ToCity'        => 'EAST BOSTON',
        'FromState'     => 'MA',
        'ToZip'         => '02128',
        'ToState'       => 'MA',
        'To'            => '+16179970269',
        'ToCountry'     => 'US',
        'FromCountry'   => 'US',
        'SmsMessageSid' => 'SM12ac8c0c64e01188d32fa2d4b40f1b5d',
        'ApiVersion'    => '2010-04-01',
        'FromCity'      => 'WOBURN',
        'SmsStatus'     => 'received',
        'FromZip'       => '02043'
      }
    end

    context "when properly authenticated as Twilio" do
      before(:each) do
        post 'create', @params.merge({'AccountSid' => Twilio::ACCOUNT_SID})
      end

      it "should return some text with a 200 status" do
        response.status.should == 200
        response.content_type.should == 'text/plain'
        response.body.should_not be_blank
      end

      it "should record a RawSms" do
        RawSms.count.should == 1

        raw_sms = RawSms.first
        raw_sms.from.should == "+14152613077"
        raw_sms.body.should == "ate kitten"
        raw_sms.twilio_sid.should == "SM12ac8c0c64e01188d32fa2d4b40f1b5d"
      end
    end

    context "when properly authenticated as the heartbeat" do
      it "should return a short code with a 200 status" do
        post('create', {'Heartbeat' => SmsController::HEARTBEAT_CODE})
        response.status.should == 200
        response.body.should == 'ok'
      end
    end

    context "when authentication as Twilio or the heartbeat fails" do
      it "should return a blank 404" do
        post :create, @params.merge({'AccountSid' => Twilio::ACCOUNT_SID + "youbrokeit"})

        response.status.should == 404
        response.body.should be_blank
      end
    end
  end
end
