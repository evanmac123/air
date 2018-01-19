require 'rails_helper'

RSpec.describe RemoveInvalidUserPhoneNumberJob, type: :job do
  it "returns nil is user cannot be found" do
    result = RemoveInvalidUserPhoneNumberJob.perform_now(phone_number: "+12223334444")
    expect(result).to eq(nil)
  end

  it "removes users phone number" do
    _user = FactoryBot.create(:user, phone_number: "+12223334444")

    RemoveInvalidUserPhoneNumberJob.perform_now(phone_number: "+12223334444")

    expect(User.first.phone_number).to eq("")
  end
end
