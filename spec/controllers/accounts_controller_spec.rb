require 'spec_helper'

describe AccountsController do
  describe "#update" do
    it "should not let a user update their mobile number to one that's already taken" do
      subject.stubs(:ping)

      original_number = "+14155551212"
      new_number = "+18089761234"

      user = FactoryGirl.create(:user, phone_number: original_number)
      FactoryGirl.create(:user, phone_number: new_number)

      sign_in_as(user)
      request.env['HTTP_REFERER'] = account_settings_path
      put :update, user: {phone_number: new_number}

      expect(flash[:failure]).to include("Sorry, but that phone number has already been taken. Need help? Contact support@airbo.com")
      expect(user.reload.phone_number).to eq(original_number)
    end
  end
end
