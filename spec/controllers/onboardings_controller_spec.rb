require 'spec_helper'

describe OnboardingsController do
  let(:valid_params){
    {
      name: "Test Name", 
      email: "test@test.com", 
      organization: "Test Company", 
      topic_board_id: @demo.id 
    }
  }

  before do
    @tb = FactoryGirl.create(:topic_board, :valid)
    @demo = @tb.board
  end

  describe "#new" do
    context 'with valid params' do
      it "proceeds" do
        get :new, valid_params
        expect(response.status).to eq(200)
      end
    end

    context 'with invalid params' do
      context 'missing email' do
        it "restarts" do
          get :new, valid_params.except(:email)
          expect(flash[:failure]).to eq "Your onboarding link appears to be invalid. Please click 'Contact Us' or 'Schedule a Demo' links below for assistance."
          expect(response).to redirect_to(root_path)
        end
      end
    end
  end

  describe '#create' do
    context 'with valid params' do

      it "proceeds with onboardings" do
        post :create, valid_params

        expect(response.status).to eq(200)
        expect(response.body).to eq(valid_json)
      end
    end

    context 'with invalid params' do
      context 'missing email' do
        it "restarts onboarding" do
          post :create, valid_params.except(:email)
          expect(response.status).to eq(422)
          expect(response.headers["X-Message"]).to_not be_nil 
        end
      end

      context 'missing name' do
        it "restarts onboarding" do
          post :create, valid_params.except(:name)
          expect(response.status).to eq(422)
          expect(response.headers["X-Message"]).to_not be_nil 
        end
      end

      context 'missing org' do
        it "restarts onboarding" do
          post :create, valid_params.except(:organization)
          expect(response.status).to eq(422)
          expect(response.headers["X-Message"]).to_not be_nil 
        end
      end
    end
  end

  def valid_json
    user_onboarding = UserOnboarding.last
    user = user_onboarding.user
    {
      user_onboarding: user_onboarding.id, 
      hash: user_onboarding.auth_hash, 
      user: user.data_for_mixpanel.merge({time: DateTime.now })
    }.to_json

  end

end
