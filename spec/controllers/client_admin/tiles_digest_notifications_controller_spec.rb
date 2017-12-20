require "spec_helper"

describe ClientAdmin::TilesDigestNotificationsController do
  context "create" do
    it "should send test digests" do
      demo = FactoryBot.create(:demo)
      client_admin = FactoryBot.create(:client_admin, demo: demo)

      TilesDigestForm.any_instance.expects(:submit_send_test_digest)

      sign_in_as(client_admin)
      request.env['HTTP_REFERER'] = '/'
      post :create, follow_up_day: 'Friday', digest: {follow_up_day: "Tuesday", digest_send_to: 'true', demo_id: client_admin.demo_id}, digest_type: "test_digest"
    end

    it "should schedule digests and followups" do
      demo = FactoryBot.create(:demo)
      client_admin = FactoryBot.create(:client_admin, demo: demo)

      TilesDigestForm.any_instance.expects(:submit_schedule_digest_and_followup)

      sign_in_as(client_admin)
      request.env['HTTP_REFERER'] = '/'
      post :create, follow_up_day: 'Friday', digest: {follow_up_day: "Tuesday", digest_send_to: 'true', demo_id: client_admin.demo_id}
    end

    it "should prevent digests from being sent if the current user's demo does not match the demo on the DOM" do
      demo = FactoryBot.create(:demo)
      client_admin = FactoryBot.create(:client_admin, demo: demo)

      TilesDigestForm.expects(:new).never

      sign_in_as(client_admin)
      request.env['HTTP_REFERER'] = '/'
      post :create, follow_up_day: 'Friday', digest: {follow_up_day: "Tuesday", digest_send_to: 'true', demo_id: 0}

      expect(flash[:failure]).to be_present
    end
  end
end
