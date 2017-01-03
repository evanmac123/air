require 'spec_helper'

describe BoardMembershipsController do
  describe "destroy" do
    def mock_service_with_errors(klass, method, messages)
      mock_service = mock(klass.to_s)
      mock_service.stubs(method.to_sym).returns(false)
      mock_service.stubs(:error_messages).returns(messages)

      klass.stubs(:new).returns(mock_service)

      mock_service
    end

    before do
      subject.stubs(:ping)

      request.env["HTTP_REFERER"] = ""
    end

    let (:fake_error_messages) {["that didn't work", "maybe say Simon Says"]}
    let (:user) {FactoryGirl.create(:user)}

    context "when removing the user from the board fails" do
      it "should put error messages in the flash" do
        mock_remover = mock_service_with_errors(RemoveUserFromBoard, "remove!", fake_error_messages)

        user.add_board(FactoryGirl.create(:demo))
        expect(user.demos.length > 1).to be_truthy

        sign_in_as(user)
        post(:destroy, id: user.demo.id, as: user)

        expect(mock_remover).to have_received(:"remove!").once
        expect(flash[:success]).not_to be_present
        expect(flash[:failure]).to eq("Sorry, we weren't able to remove you from that board: that didn't work, maybe say Simon Says.")
      end
    end

    context "when deleting the user's account fails" do
      it "should put error messages in the flash" do
        mock_deleter = mock_service_with_errors(DeleteUserAccount, "delete!", fake_error_messages)

        expect(user.demos.length).to eq(1)

        sign_in_as(user)
        post(:destroy, id: user.demo.id, as: user)

        expect(mock_deleter).to have_received("delete!").once
        expect(flash[:success]).not_to be_present
        expect(flash[:failure]).to eq("Sorry, we weren't able to remove you from that board: that didn't work, maybe say Simon Says.")
      end
    end
  end
end
