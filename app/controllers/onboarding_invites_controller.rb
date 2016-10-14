class OnboardingInvitesController < ApplicationController
  skip_before_filter :authorize
  skip_before_filter :authorize_with_onboarding_auth_hash
  layout 'onboarding'

  def new
    @user_onboarding = UserOnboarding.includes([:user, :onboarding]).find(params[:user_onboarding_id])
  end

  def create
    user_onboarding = UserOnboarding.includes([:user, :onboarding]).find(params[:user_onboarding_id])

    UserOnboardingNotifier.notify_all(user_onboarding, params[:user_onboarding_emails])

    user_onboarding.update_attributes(shared: true)

    redirect_to user_onboarding_path(user_onboarding, shared: true, state: user_onboarding.state)
  end
end
