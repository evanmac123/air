class UserOnboardingsController < ApplicationController
  skip_before_filter :authorize, only: [:show]
  layout 'onboarding'

  def show
    @user_onboarding = UserOnboarding.includes([:user, :onboarding]).find(params[:id])
  end

  def update
    user_onboarding_updater = UserOnboardingUpdater.new(user_onboarding_params)

    if user_onboarding_updater.save
      redirect_to "/myairbo/#{params[:id]}"
    else
      #why might this fail??
    end
  end

  private
    def user_onboarding_params
      {
        params[:id],
        params[:topic_board_id]
      }
    end
end
