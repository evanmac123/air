require 'spec_helper'

describe PotentialUserConversionsController do
  describe "POST create" do
    it "should send appropriate pings" do
      subject.stubs(:ping)

      user = FactoryGirl.create(:user)
      demo = user.demo
      potential_user = FactoryGirl.create(:potential_user, email: "john@snow.com", demo: demo, primary_user: user)
      potential_user.is_invited_by user

      sign_in_as(potential_user)

      post :create

      expect(subject).to have_received(:ping).with("Saw welcome pop-up", {action: "Clicked 'Next'"}, subject.current_user)
    end
  end
end
