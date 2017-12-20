require 'spec_helper'

describe Admin::OrganizationsController do
  describe "POST destroy" do
    it "destroys org" do
      admin = FactoryBot.create(:site_admin)
      org = FactoryBot.create(:organization)

      sign_in_as(admin)
      post :destroy, id: org.slug

      expect(response.status).to eq(302)
      expect(flash[:success]).to include("deleted")
    end
  end
end
