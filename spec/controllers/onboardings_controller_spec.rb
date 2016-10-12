require 'spec_helper'

describe OnboardingsController do
  let(:valid_params){{
    name: "Test Name", email: "test@test.com", organization: "Test Company", topic_board_id: @demo.id } }
  before do
    @tb = FactoryGirl.create(:topic_board, :valid)
    @demo = @tb.board
  end

  describe '#create' do
    context 'with valid params' do

      it "return json with 200 status" do
        post :create, valid_params

        expect(response.status).to eq(200)

        body = {"success"=>true, "user_onboarding"=>1, "hash"=>"1ead90e2f3fc89116b57681993316cfaa2e4a066"}.to_json

        expect(response.body).to eq(body)
      end
    end

    context 'with invalid params' do
      context 'missing email' do
        xit "redirects to root" do
          post :create, valid_params.except(:email)
          expect(response.status).to eq(200)
          expect(response).to redirect_to(root_path)
        end
      end

      context 'missing name' do
        xit "redirects to root" do
          post :create, valid_params.except(:name)

          expect(response.status).to eq(200)

          expect(response).to redirect_to(root_path)
        end
      end

      context 'missing org' do
        xit "redirects to root" do
          post :create, valid_params.except(:organization)

          expect(response.status).to eq(200)

          expect(response).to redirect_to(root_path)
        end
      end
    end
  end

end
