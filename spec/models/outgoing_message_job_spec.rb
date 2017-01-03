require 'spec_helper'

describe SMS::OutgoingMessageJob do
  before(:each) do
    Twilio::SMS.stubs(:create)
    Airbrake.stubs(:notify)

    @job = SMS::OutgoingMessageJob.new("+14155551212", "+16175551212", "hey there")
  end

  context "#perform" do
    it "should post the message to Twilio" do
      @job.perform
      expect(Twilio::SMS).to have_received(:create).with(:from => "+14155551212", :to => "+16175551212", :body => "hey there")
    end

    it "should record an OutgoingSms" do
      @job.perform

      expect(OutgoingSms.count).to eq(1)

      outgoing_sms = OutgoingSms.first
      expect(outgoing_sms.body).to eq('hey there')
      expect(outgoing_sms.to).to eq("+16175551212")
      expect(outgoing_sms.mate).to be_nil
    end

    context "when the number is one of our dummy numbers (in the 999 area code)" do
      before(:each) do
        Twilio::SMS.stubs(:create).raises(Twilio::APIError, "Error #21401: +19995551212 is not a valid phone number")
        @job = SMS::OutgoingMessageJob.new("+14155551212", "+19995551212", "hey there")
      end

      it "should not try to send" do
        @job.perform
        expect(Twilio::SMS).to have_received(:create).never
      end
    end

    context "when the post to Twilio raises an error" do
      before(:each) do
        @exception = RuntimeError.new("everything went to hell")
        Twilio::SMS.stubs(:create).raises(@exception)
      end

      it "should alert Airbrake" do
        @job.perform
        expect(Airbrake).to have_received(:notify).with(:error_class => @exception.class, :error_message => @exception.message, :parameters => {:from => "+14155551212", :to => "+16175551212", :body => "hey there"})
      end
    end
  end
end
