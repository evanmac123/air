require 'rails_helper'

RSpec.describe SmsSenderJob, type: :job do
  let(:user) { FactoryBot.create(:user, phone_number: "+14443332222", receives_sms: true) }

  it "returns nil if to_number is blank" do
    result = SmsSenderJob.perform_now(to_number: "", body: "body")

    expect(result).to eq(nil)
  end

  it "asks twilio to create a text message from short code" do
    user
    $twilio_client.expects(:messages).returns($twilio_client)
    $twilio_client.expects(:create).with(from: TWILIO_SHORT_CODE, to: "+14443332222", body: "body")

    SmsSenderJob.perform_now(to_number: "+14443332222", body: "body")
  end

  it "calls RemoveInvalidUserPhoneNumberJob if $twilio_client.create raises Twilio::REST::RestError" do
    user
    $twilio_client.stubs(:messages).returns($twilio_client)
    $twilio_client.stubs(:create).raises(Twilio::REST::RestError.new("invalid number", 1, 500))

    RemoveInvalidUserPhoneNumberJob.expects(:perform_later).with(phone_number: "+14443332222")

    SmsSenderJob.perform_now(to_number: "+14443332222", body: "body")
  end
end
