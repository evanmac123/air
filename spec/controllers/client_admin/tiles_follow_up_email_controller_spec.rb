require 'spec_helper'

describe ClientAdmin::TilesFollowUpEmailController do
  describe "DELETE destroy" do
    it "should delete follow up email " do
      demo = FactoryGirl.create(:demo)
      client_admin = FactoryGirl.create(:client_admin, demo: demo)
      tile = FactoryGirl.create(:tile, demo: demo)
      digest = TilesDigest.create(demo: demo, sender: client_admin)
      digest.tiles << tile

      followup = digest.create_follow_up_digest_email(
        send_on: Date.new(2013, 7, 1)
      )

      sign_in_as(client_admin)

      delete :destroy, id: followup.id, format: :js

      expect(response.status).to eq(200)
      expect(FollowUpDigestEmail.count).to eq(0)
    end
  end
end
