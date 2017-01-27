require 'spec_helper'

describe Admin::OrganizationsController do
  describe "POST destroy" do
    it "destroys org" do
      admin = FactoryGirl.create(:site_admin)
      org = FactoryGirl.create(:organization)

      sign_in_as(admin)
      post :destroy, id: org.slug

      expect(response.status).to eq(302)
      expect(flash[:success]).to include("deleted")
    end
  end
end
