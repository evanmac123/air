require 'spec_helper'

describe Api::BoardMembershipsController do
  describe "PUT update" do
    let(:user) { FactoryGirl.create(:user) }

    it "renders access denied if not authenticated" do
      put(:update, { id: user.board_memberships.first.id, board_membership: { notification_pref_cd: BoardMembership.unsubscribe }, format: :json })

      expect(response.status).to eq(401)
    end

    it "updats the board membership and returns json of the bm" do
      sign_in_as(user)

      expect(BoardMembership.first.notification_pref_cd).to eq(BoardMembership.notification_prefs[:both])

      put(:update, { id: BoardMembership.first.id, board_membership: { notification_pref_cd: BoardMembership.unsubscribe }, format: :json })

      body = JSON.parse(response.body)

      expect(BoardMembership.first.notification_pref_cd).to eq(BoardMembership.notification_prefs[:unsubscribe])
      expect(response.status).to eq(200)

      expect(body["board_membership"]["user_id"]).to eq(user.id)
    end
  end
end
