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

        body = {"success"=>true, "user_onboarding"=>2, "hash"=>"9c0c957e612c2d2821394b95bce61af20995a0e1"}.to_json

        expect(response.body).to eq(body)
      end
    end

    context 'with invalid params' do
      context 'missing email' do
        xit "redirects to root" do
          post :create, valid_params.except(:email)
          expect(response.status).to eq(302)

          expect(response).to redirect_to(root_path)
        end
      end

      context 'missing name' do
        xit "redirects to root" do
          post :create, valid_params.except(:name)

          expect(response.status).to eq(302)

          expect(response).to redirect_to(root_path)
        end
      end

      context 'missing org' do
        xit "redirects to root" do
          post :create, valid_params.except(:organization)

          expect(response.status).to eq(302)

          expect(response).to redirect_to(root_path)
        end
      end
    end
  end
end
