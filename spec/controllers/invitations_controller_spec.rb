require 'spec_helper'

describe InvitationsController do
  describe "GET show" do
    it "should send appropriate pings" do
      subject.stubs(:record_mixpanel_ping)
      subject.stubs(:email_clicked_ping)

      user = FactoryGirl.create(:client_admin)
      inviter = FactoryGirl.create(:user)

      get :show, id: user.invitation_code, demo_id: inviter.demo.id, referrer_id: inviter.id

      expect(subject).to have_received(:record_mixpanel_ping).with(subject.current_user)
      expect(subject).to have_received(:email_clicked_ping).with(subject.current_user)
    end
  end
end
