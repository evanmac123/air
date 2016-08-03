require 'spec_helper'

metal_testing_hack(SmsController)

describe SmsController do
  describe "#create" do
    before(:each) do
      subject.stubs(:ping)
      # We don't use hardly any of these fields, but this is what Twilio
      # sends.

      @user = FactoryGirl.create :user, :phone_number => "+14152613077", :demo => (FactoryGirl.create(:demo, phone_number: "+14158675309"))
      @original_mt_texts_today = @user.mt_texts_today

      @params = {
        'From'          => @user.phone_number,
        'Body'          => 'ate kitten',
        'SmsSid'        => 'SM12ac8c0c64e01188d32fa2d4b40f1b5d',
        'ToCity'        => 'EAST BOSTON',
        'FromState'     => 'MA',
        'ToZip'         => '02128',
        'ToState'       => 'MA',
        'To'            => '+14158675309',
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

      it "should record a IncomingSms" do
        IncomingSms.count.should == 1

        incoming_sms = IncomingSms.first
        incoming_sms.from.should == "+14152613077"
        incoming_sms.body.should == "ate kitten"
        incoming_sms.twilio_sid.should == "SM12ac8c0c64e01188d32fa2d4b40f1b5d"
      end

      it "should record an OutgoingSms" do
        OutgoingSms.count.should == 1

        outgoing_sms = OutgoingSms.first
        outgoing_sms.mate.should == IncomingSms.first
        outgoing_sms.to.should == "+14152613077"
        outgoing_sms.body.should == response.body
      end

      it "should bump the user's mt_texts_today" do
        (@user.reload.mt_texts_today - @original_mt_texts_today).should == 1
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
