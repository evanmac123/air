require 'rails_helper'

describe ClientAdmin::SharesHelper do
  before do
    @helper = Object.new.extend(ClientAdmin::SharesHelper)
  end

  describe "#digest_sent_modal_text" do
    it "returns the correct text for 'digest_delivered' type" do
      expect(helper.digest_sent_modal_text("digest_delivered")).to eq("Your Tiles have been successfully sent. New Tiles you post will appear in the email preview.")
    end

    it "calls the correct template 'test_digest' type" do
      helper.expects(:sms_sent_template_message).never
      helper.expects(:test_email_sent_message_template).with("Tiles Digest")

      helper.digest_sent_modal_text("test_digest")
    end

    it "calls the correct template 'test_digest_with_sms' type" do
      helper.expects(:sms_sent_template_message).returns("SMS TEMPLATE")
      helper.expects(:test_email_sent_message_template).with("Tiles Digest", "SMS TEMPLATE")

      helper.digest_sent_modal_text("test_digest_with_sms")
    end

    it "calls the correct template 'test_digest_and_follow_up' type" do
      helper.expects(:sms_sent_template_message).never
      helper.expects(:test_email_sent_message_template).with("Tiles Digest and Follow-up Email")

      helper.digest_sent_modal_text("test_digest_and_follow_up")
    end

    it "calls the correct template 'test_digest_and_follow_up_with_sms' type" do
      helper.expects(:sms_sent_template_message).returns("SMS TEMPLATE")
      helper.expects(:test_email_sent_message_template).with("Tiles Digest and Follow-up Email", "SMS TEMPLATE")

      helper.digest_sent_modal_text("test_digest_and_follow_up_with_sms")
    end
  end

  describe "#sms_sent_template_message" do
    describe "when user has a phone number" do
      it "returns the message" do
        helper.expects(:current_user).returns(user_with_phone).twice

        expect(helper.sms_sent_template_message).to eq("Any test text messages have been sent to #{user_with_phone.phone_number}")
      end
    end

    describe "when user does not have a phone number" do
      it "returns the message" do
        helper.expects(:current_user).returns(user_without_phone)

        expect(helper.sms_sent_template_message).to eq("No test text messages could be sent because your phone number is not set in Airbo. You may add your phone number #{link_to 'here', edit_account_settings_path}")
      end
    end
  end

  describe "#test_email_sent_message_template" do
    it "returns the given string ins template" do
      helper.expects(:current_user).returns(user_with_phone)

      expect(helper.test_email_sent_message_template("EMAIL", "SMS")).to eq("A test EMAIL has been sent to #{user_with_phone.email}. SMS.")
    end
  end

  def user_with_phone
    OpenStruct.new(email: "test@airbo.com", phone_number: "+4243532222")
  end

  def user_without_phone
    OpenStruct.new(email: "test@airbo.com", phone_number: nil)
  end
end
