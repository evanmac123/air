require 'spec_helper'

describe OnboardingsController do
  describe '#create' do
    context 'with valid params' do
      it "redirects to Onboardings#show" do
        get :create, valid_params

        expect(response.status).to eq(302)

        expect(response).to redirect_to("/myairbo/#{Onboarding.last.id}")
      end
    end

    context 'with invalid params' do
      context 'missing onboard flag' do
        it "redirects to root" do
          get :create, valid_params.except(:onboard)

          expect(response.status).to eq(302)

          expect(response).to redirect_to(root_path)
        end
      end

      context 'missing email' do
        it "redirects to root" do
          get :create, valid_params.except(:email)

          expect(response.status).to eq(302)

          expect(response).to redirect_to(root_path)
        end
      end

      context 'missing name' do
        it "redirects to root" do
          get :create, valid_params.except(:name)

          expect(response.status).to eq(302)

          expect(response).to redirect_to(root_path)
        end
      end

      context 'missing org' do
        it "redirects to root" do
          get :create, valid_params.except(:organization)

          expect(response.status).to eq(302)

          expect(response).to redirect_to(root_path)
        end
      end
    end
  end

  def valid_params
      {
        onboard: true,
        name: "Test Name",
        email: "test@test.com",
        organization: "Test Company"
      }
  end
end
