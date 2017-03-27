class UserOnboardingsController < ApplicationController
  layout 'onboarding'

  def show
    @user_onboarding = UserOnboarding.includes([:user, :onboarding]).find(params[:id])
    @board = @user_onboarding.board
    sign_in(@user_onboarding.user)

    @tiles = Tile.displayable_categorized_to_user(current_user, nil)
  end

  def create
    user_onboarding_init = UserOnboardingInitializer.new(user_onboarding_params)
    if should_onboard? && user_onboarding_init.save
      user_onboarding = user_onboarding_init.user_onboarding
      render json: { success: true,
                     user_onboarding: user_onboarding.id,
                     hash: user_onboarding.auth_hash
      },
      location: user_onboarding_path(user_onboarding), status: :ok
    else
      head :unprocessable_entity, response.headers["X-Message"] = user_onboarding_init.error
    end
  end

  private

    def user_onboarding_params
      params.require(:user_onboarding).permit(:email, :onboarding_id, :name, :completed, :more_info)
    end

    def should_onboard?
      @user = User.where(email: params[:user_onboarding][:email]).first_or_initialize
      @user.user_onboarding.nil?
    end
end
