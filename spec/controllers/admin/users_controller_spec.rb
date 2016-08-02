require 'spec_helper'

describe Admin::UsersController do
  describe "PUT update" do
    context "admin status is updated" do
      it "updates user and sends ping" do
        subject.stubs(:ping)
        admin = FactoryGirl.create(:site_admin)
        user = FactoryGirl.create(:user)
        user.demos << Demo.first
        user.save

        sign_in_as(admin)

        put :update, demo_id: Demo.first.id, id: user.slug, user: { is_client_admin: true }

        expect(response.status).to eq(302)
        expect(subject).to have_received(:ping).with("claimed account", {source: 'Site Admin'}, subject.current_user)
      end
    end

    context "admin status is not updated" do
      it "updates user and does not send ping" do
        subject.stubs(:ping)
        admin = FactoryGirl.create(:site_admin)
        user = FactoryGirl.create(:user)
        user.demos << Demo.first
        user.save

        sign_in_as(admin)

        put :update, demo_id: Demo.first.id, id: user.slug, user: {}

        expect(response.status).to eq(302)
        expect(subject).to have_received(:ping).never.with("claimed account", {source: 'Site Admin'}, subject.current_user)
      end
    end
  end
end
