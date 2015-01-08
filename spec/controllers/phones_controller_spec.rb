require 'spec_helper'

describe PhonesController do
  describe '#update' do
    context 'with an incorrect validation code' do
      def old_phone_number
        "+14155551212"
      end

      def new_phone_number
        "+18086829592"
      end

      before do
        @user = FactoryGirl.create(:user, phone_number: old_phone_number, new_phone_number: new_phone_number, new_phone_validation: "1234")

        sign_in_as(@user)
        request.env['HTTP_REFERER'] = edit_account_settings_path
        put :update, user: {new_phone_validation: '6789'}
      end

      it "should not change the user's phone number" do
        @user.reload.phone_number.should == old_phone_number
      end

      it "should have an appropriate error in the flash" do
        flash[:failure].should include(subject.send :wrong_phone_validation_code_error)
      end
    end
  end
end
