require "spec_helper"

describe ClientAdmin::TilesDigestNotificationsController do
  context "create" do
    it "should record the user IDs that the followup should go to" do
      subject.stubs(:ping)
      demo = FactoryGirl.create(:demo)
      client_admin = FactoryGirl.create(:client_admin, demo: demo)
      other_users = FactoryGirl.create_list(:user, 2, demo: demo)
      expected_user_ids_to_deliver_to = ([client_admin.id] + other_users.map(&:id)).sort

      sign_in_as(client_admin)
      request.env['HTTP_REFERER'] = '/' # so redirect_to :back works
      post :create, follow_up_day: 'Friday', digest: {follow_up_day: "Tuesday", digest_send_to: 'true'}

      follow_up = FollowUpDigestEmail.last
      expect(follow_up.user_ids_to_deliver_to.sort).to eq(expected_user_ids_to_deliver_to)
    end
  end
end
