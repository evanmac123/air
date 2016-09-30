
    #TODO remove this controller?
class Api::V1::OnboardingsController < ApplicationController
  skip_before_filter :authorize

  def create
    onboarding_initializer = OnboardingInitializer.new(onboarding_params)
    cookies[:user_onboarding]=  onboarding_initializer.user_onboarding.auth_hash
    render json: { success: onboarding_initializer.save, user_onboarding: onboarding_initializer.user_onboarding_id }
  end

  private

    def onboarding_params
      {
        email:        params[:email],
        name:         params[:name],
        organization: params[:organization],
        board_id: params[:topic_board_id]
      }
    end
end
