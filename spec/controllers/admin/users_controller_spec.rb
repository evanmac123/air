require 'spec_helper'

describe Admin::UsersController do
  describe "PUT update" do
    before(:each) do
      request.env["HTTP_REFERER"] = "goes back"
    end

    context "admin status is updated" do
      it "updates user and sends ping" do
        subject.stubs(:ping)
        admin = FactoryBot.create(:site_admin)
        user = FactoryBot.create(:user)
        user.demos << Demo.first
        user.save

        sign_in_as(admin)

        put :update, demo_id: Demo.first.id, id: user.slug, user: { is_client_admin: true }

        expect(response.status).to eq(302)
      end
    end

    context "admin status is not updated" do
      it "updates user and does not send ping" do
        subject.stubs(:ping)
        admin = FactoryBot.create(:site_admin)
        user = FactoryBot.create(:user)
        user.demos << Demo.first
        user.save

        sign_in_as(admin)

        put :update, demo_id: Demo.first.id, id: user.slug, user: {}

        expect(response.status).to eq(302)
      end
    end
  end
end
