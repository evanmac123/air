require 'spec_helper'

describe SMS do
  describe ".send_message" do
    before do
      Twilio::SMS.stubs(:create)
    end

    it "can send to either a User or phone number" do
      user = Factory :user, :phone_number => "+14155551212"

      SMS.send_message(user, "hi 1")
      SMS.send_message("+16175551212", "hi 2")

      Delayed::Worker.new.work_off(10)

      Twilio::SMS.should have_received(:create).with(:to => "+14155551212", :from => TWILIO_PHONE_NUMBER, :body => "hi 1")
      Twilio::SMS.should have_received(:create).with(:to => "+16175551212", :from => TWILIO_PHONE_NUMBER, :body => "hi 2")
    end

    context "when sending to a User" do
      before do
        @user = Factory :user, :phone_number => "+14155551212"
      end

      context "whose demo has no custom phone number" do
        before do
          @user.demo.phone_number.should be_nil
        end

        it "should send from the default number" do
          SMS.send_message(@user, "hi")
          Delayed::Worker.new.work_off(10)

          Twilio::SMS.should have_received(:create).with(:to => "+14155551212", :from => TWILIO_PHONE_NUMBER, :body => "hi")
        end
      end

      context "whose demo has a custom phone number" do
        before do
          @user.demo.update_attribute(:phone_number, "+16175551212")
        end

        it "should send from that number" do
          SMS.send_message(@user, "hi")
          Delayed::Worker.new.work_off(10)

          Twilio::SMS.should have_received(:create).with(:to => "+14155551212", :from => "+16175551212", :body => "hi")
        end
      end

      it "should bump the user's mt_texts_today" do
        original_mt_texts_today = @user.mt_texts_today
        3.times {SMS.send_message(@user, 'hey there')}
        Delayed::Worker.new.work_off(10)
        
        (@user.reload.mt_texts_today - original_mt_texts_today).should == 3
      end

      it "should send nothing if the user is muted" do
        Timecop.freeze(1)
        @user.update_attributes(:last_muted_at => (23.hours + 59.minutes + 59.seconds).ago)
        SMS.send_message(@user, "hi")
        Delayed::Worker.new.work_off(10)
        Twilio::SMS.should have_received(:create).never

        @user.update_attributes(:last_muted_at => (24.hours.ago))
        SMS.send_message(@user, "hey")
        Delayed::Worker.new.work_off(10)
        Twilio::SMS.should have_received(:create)
        
        Timecop.return
      end
    end
  end
end
