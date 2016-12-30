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
        expect(response.status).to eq(200)
        expect(response.content_type).to eq('text/plain')
        expect(response.body).not_to be_blank
      end

      it "should record a IncomingSms" do
        expect(IncomingSms.count).to eq(1)

        incoming_sms = IncomingSms.first
        expect(incoming_sms.from).to eq("+14152613077")
        expect(incoming_sms.body).to eq("ate kitten")
        expect(incoming_sms.twilio_sid).to eq("SM12ac8c0c64e01188d32fa2d4b40f1b5d")
      end

      it "should record an OutgoingSms" do
        expect(OutgoingSms.count).to eq(1)

        outgoing_sms = OutgoingSms.first
        expect(outgoing_sms.mate).to eq(IncomingSms.first)
        expect(outgoing_sms.to).to eq("+14152613077")
        expect(outgoing_sms.body).to eq(response.body)
      end

      it "should bump the user's mt_texts_today" do
        expect(@user.reload.mt_texts_today - @original_mt_texts_today).to eq(1)
      end
    end

    context "when properly authenticated as the heartbeat" do
      it "should return a short code with a 200 status" do
        post('create', {'Heartbeat' => SmsController::HEARTBEAT_CODE})
        expect(response.status).to eq(200)
        expect(response.body).to eq('ok')
      end
    end

    context "when authentication as Twilio or the heartbeat fails" do
      it "should return a blank 404" do
        post :create, @params.merge({'AccountSid' => Twilio::ACCOUNT_SID + "youbrokeit"})

        expect(response.status).to eq(404)
        expect(response.body).to be_blank
      end
    end
  end
end
