require 'spec_helper'

describe PhonesController do
  describe "#update" do
    it "should not let a user update their mobile number to one that's already taken" do
      subject.stubs(:ping)

      original_number = "+14155551212"
      new_number = "+18089761234"

      user = FactoryBot.create(:user, phone_number: original_number)
      FactoryBot.create(:user, phone_number: new_number)

      sign_in_as(user)
      request.env['HTTP_REFERER'] = account_settings_path
      put :update, user: {phone_number: new_number}

      expect(flash[:failure]).to include("Sorry, but that phone number has already been taken. Need help? Contact support@airbo.com")
      expect(user.reload.phone_number).to eq(original_number)
    end
  end

  describe '#validate' do
    context 'with an incorrect validation code' do
      def old_phone_number
        "+14155551212"
      end

      def new_phone_number
        "+18086829592"
      end

      before do
        subject.stubs(:ping)

        @user = FactoryBot.create(:user, phone_number: old_phone_number, new_phone_number: new_phone_number, new_phone_validation: "1234")

        sign_in_as(@user)
        request.env['HTTP_REFERER'] = edit_account_settings_path
        put :validate, user: {new_phone_validation: '6789'}
      end

      it "should not change the user's phone number" do
        expect(@user.reload.phone_number).to eq(old_phone_number)
      end

      it "should have an appropriate error in the flash" do
        expect(flash[:failure]).to include(subject.send :wrong_phone_validation_code_error)
      end
    end
  end
end
