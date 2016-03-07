require 'spec_helper'

describe BoardsController do
  describe "#create" do
    context "when logged in as a guest user" do
      before do
        @guest_user = FactoryGirl.create(:guest_user)
        BoardsController.any_instance.stubs(:current_user).returns(@guest_user)
        BoardsController.any_instance.stubs(:sign_in).returns(true)

        post :create, user: {name: 'jimmy jones', email: 'jim@jones.com', password: 'heyhey'}, board: {name: 'jimboard'}
      end

      it "should associate that guest with the real user we create" do
        user = User.last
        user.should be_present
        @guest_user.reload.converted_user.should == User.last
      end
    end
  end
end
