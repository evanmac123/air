require 'spec_helper'

describe Admin::DemosController do
  describe "POST create" do
    it "creates board" do
      attrs = FactoryBot.attributes_for(:demo)
      admin = FactoryBot.create(:site_admin)

      expect(Demo.count).to eq(1)

      sign_in_as(admin)

      post :create, demo: attrs

      expect(Demo.count).to eq(2)
      expect(response.status).to eq(302)
      expect(flash[:success]).to be_present
    end
  end
end
