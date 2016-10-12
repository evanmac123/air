class OnboardingInvitesController < ApplicationController
  skip_before_filter :authorize
  skip_before_filter :authorize_with_onboarding_auth_hash
  layout 'onboarding'

  def new
    @user_onboarding = UserOnboarding.includes([:user, :onboarding]).find(params[:user_onboarding_id])
  end

  def create
    user_onboarding = UserOnboarding.includes([:user, :onboarding]).find(params[:user_onboarding_id])

    entry_state = user_onboarding.state

    UserOnboardingNotifier.notify_all(user_onboarding, params[:user_onboarding_emails])

    user_onboarding.update_state

    redirect_to user_onboarding_path(user_onboarding, shared: true, state: entry_state)
  end
end
