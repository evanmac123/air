require 'spec_helper'

xdescribe PotentialUserConversionsController do
  describe "POST #create" do
    context 'when session hash includes potential_user_id' do
      before do
        user = FactoryBot.create(:user)
        demo = user.demo

        potential_user = FactoryBot.create(:potential_user, email: "john@snow.com", demo: demo, primary_user: user)

        potential_user.is_invited_by(user)

        post :create, { potential_user_name: "Test Name" }, { potential_user_id: potential_user.id }
      end

      context 'and a valid name in entered' do
        it "welcomes converted user by name" do
          expect(flash[:success]).to eq("Welcome, Test Name")
        end

        it "redirects to activity_path" do
          expect(response).to redirect_to(activity_path)
        end
      end
    end
  end
end
