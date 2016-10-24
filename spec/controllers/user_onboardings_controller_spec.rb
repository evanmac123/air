require 'spec_helper'

describe UserOnboardingsController do
  let(:valid_params){ { user_onboarding: {
    name: "Test Name", email: "test@test.com", onboarding_id: @onboarding.id } } }
  before do
    @root_user_onboarding = FactoryGirl.create(:user_onboarding)
    @onboarding = @root_user_onboarding.onboarding
  end

  describe '#create' do
    context 'with valid params' do

      it "return json with 200 status" do
        post :create, valid_params

        expect(response.status).to eq(200)

        body = {"success"=>true, "user_onboarding"=>UserOnboarding.last.id, "hash"=>UserOnboarding.last.auth_hash}.to_json

        expect(response.body).to eq(body)
      end
    end
  end
end
