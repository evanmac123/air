class UserOnboardingsController < ApplicationController
  skip_before_filter :authorize, only: [:show]
  layout 'onboarding'

  def show
    @user_onboarding = UserOnboarding.includes([:user, :onboarding]).find(params[:id])
  end
end
