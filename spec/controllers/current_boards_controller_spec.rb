require 'spec_helper'

describe CurrentBoardsController do
  describe "PUT update" do
    describe "successful current board update" do
      it "redirects to activity_path for non admin" do
        subject.stubs(:ping_board_switch)

        user = FactoryBot.create(:user)
        sign_in_as(user)

        _board_1 = user.demo
        board_2 = FactoryBot.create(:demo, name: "board_2")

        board_2.users << user

        put :update, board_id: board_2.id

        expect(response).to redirect_to activity_path
      end

      it "redirects to back for admin" do
        request.env["HTTP_REFERER"] = "back_path"
        subject.stubs(:ping_board_switch)

        client_admin = FactoryBot.create(:client_admin)
        sign_in_as(client_admin)

        _board_1 = client_admin.demo
        board_2 = FactoryBot.create(:demo, name: "board_2")

        board_2.board_memberships.create(user: client_admin, is_client_admin: true)

        put :update, board_id: board_2.id

        expect(response).to redirect_to "back_path"
      end

      it "sends correct pings" do
        subject.stubs(:ping_board_switch)

        user = FactoryBot.create(:user)
        sign_in_as(user)

        _board_1 = user.demo
        board_2 = FactoryBot.create(:demo, name: "board_2")

        board_2.users << user

        put :update, board_id: board_2.id

        expect(subject).to have_received(:ping_board_switch)
      end
    end

    describe "failed update when user not in board" do
      it "redirects to activity_path for non admin" do
        subject.stubs(:ping_board_switch)

        user = FactoryBot.create(:user)
        sign_in_as(user)

        _board_1 = user.demo
        board_2 = FactoryBot.create(:demo, name: "board_2")

        put :update, board_id: board_2.id

        expect(response).to redirect_to sign_in_path
      end
    end
  end
end
