    #TODO remove this controller?
class Api::V1::UserOnboardingsController < ApplicationController
  def update
    @user_onboarding = UserOnboarding.find(params[:id])
    @user_onboarding.update_attributes(user_onboarding_params)

    render json: { user_onboarding: @user_onboarding.attributes }
  end

  private

    def user_onboarding_params
      params.require(:user_onboarding).permit(:state, :demo_scheduled, :shared, :more_info)
    end
end
