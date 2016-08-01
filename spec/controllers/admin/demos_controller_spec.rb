require 'spec_helper'

describe Admin::DemosController do
  describe "POST create" do
    it "creates board and scehdules appropriate ping" do
      subject.stubs(:schedule_creation_ping)
      attrs = FactoryGirl.attributes_for(:demo)
      admin = FactoryGirl.create(:site_admin)

      expect(Demo.count).to eq(1)

      sign_in_as(admin)

      post :create, demo: attrs

      expect(Demo.count).to eq(2)
      expect(subject).to have_received(:schedule_creation_ping)
      expect(response.status).to eq(302)
      expect(flash[:success]).to be_present
    end
  end
end
