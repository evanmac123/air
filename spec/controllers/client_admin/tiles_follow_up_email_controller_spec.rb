require 'spec_helper'

describe ClientAdmin::TilesFollowUpEmailController do
  describe "DELETE destroy" do
    it "should delete follow up email and send ping" do
      subject.stubs(:ping)
      demo = FactoryGirl.create(:demo)
      client_admin = FactoryGirl.create(:client_admin, demo: demo)
      followup = FactoryGirl.create :follow_up_digest_email, demo: demo, tile_ids: [1, 2], send_on: Date.new(2013, 7, 1)

      sign_in_as(client_admin)

      delete :destroy, id: followup.id, format: :js

      expect(response.status).to eq(200)
      expect(FollowUpDigestEmail.count).to eq(0)
      expect(subject).to have_received(:ping).with('Followup - Cancelled', {}, subject.current_user)
    end
  end
end
