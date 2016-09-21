class Api::V1::UserOnboardingsController < ApplicationController
  def update
    @user_onboarding = UserOnboarding.find(params[:id])
    @user_onboarding.assign_attributes(user_onboarding_params)

    render json: { success: @user_onboarding.save, user_onboarding: @user_onboarding.attributes }
  end

  private

    def user_onboarding_params
      params.require(:user_onboarding).permit(:state)
    end
end
