require 'spec_helper'

describe OnboardingInvitesController do
  describe "POST create" do
    context "when multiple emails are entered" do
      it "executes notify_all for mailer" do
        user_onboarding = FactoryGirl.create(:user_onboarding)
        colleagues = "email@example.com, test@example.com"

        sign_in

        UserOnboardingNotifier.expects(:notify_all).at_most_once.returns(true)

        post :create, user_onboarding_emails: colleagues, user_onboarding_id: user_onboarding.id

        response.should redirect_to user_onboarding_path(user_onboarding, state: user_onboarding.state, shared: true)
      end
    end
  end
end
