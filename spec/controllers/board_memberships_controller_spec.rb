require 'spec_helper'

describe BoardMembershipsController do
  describe "destroy" do
    context "when removing the user from the board fails" do
      it "should put error messages in the flash" do
        fake_error_messages = ["that didn't work", "maybe say Simon Says"]
        RemoveUserFromBoard.any_instance.stubs(:"remove!").returns(false)
        RemoveUserFromBoard.any_instance.stubs(:error_messages).returns(fake_error_messages)
        request.env["HTTP_REFERER"] = ""

        user = FactoryGirl.create(:user)
        sign_in_as(user)

        post(:destroy, id: user.demo.id, as: user)
        flash[:success].should_not be_present
        flash[:failure].should == "Sorry, we weren't able to remove you from that board: that didn't work, maybe say Simon Says."
      end
    end
  end
end
