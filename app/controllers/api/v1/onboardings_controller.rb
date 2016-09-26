class Api::V1::OnboardingsController < ApplicationController
  skip_before_filter :authorize

  def create
    onboarding_initializer = OnboardingInitializer.new(onboarding_params)
    if should_onboard?
      render json: { success: onboarding_initializer.save, user_onboarding: onboarding_initializer.user_onboarding_id }
    end
  end

  private

    def should_onboard?
      @user = User.where(email: params[:email]).first_or_initialize
      @user.user_onboarding.nil?
    end

    def onboarding_params
      {
        email:        params[:email],
        name:         params[:name],
        organization: params[:organization],
        board_id: params[:topic_board_id]
      }
    end
end
