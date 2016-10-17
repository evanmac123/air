class UserOnboardingsController < ApplicationController
  skip_before_filter :authorize, only: [:show, :new, :create, :activity]
  # skip_before_filter :authorize_with_onboarding_auth_hash
  layout 'onboarding'

  def show
    @user_onboarding = UserOnboarding.includes([:user, :onboarding]).find(params[:id])
    @board = @user_onboarding.board
    sign_in(@user_onboarding.user)

    @tiles = Tile.displayable_categorized_to_user(current_user, nil)
  end

  def new
    if should_onboard?
      sign_out
      @user_onboarding_init = UserOnboardingInitializer.new(user_onboarding_params)
      @user_onboarding = UserOnboarding.new(state: 1)
      @referrer = params[:referrer]
    else
      redirect_to "/myairbo/#{@user.user_onboarding.id}"
    end
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

  def activity
    @user_onboarding = UserOnboarding.includes([:user, :onboarding]).find(params[:id])
    if request.user_agent =~ /Mobile|webOS/
      render template: "user_onboardings/activity_mobile"
    else
      #create poro to manage actiivty
      @board = @user_onboarding.board
      @chart_form = BoardStatsLineChartForm.new @board, {action_type: params[:action_type]}
      @chart = BoardStatsChart.new(@chart_form.period, @chart_form.plot_data).draw

      grid_builder = BoardStatsGrid.new(@board)
      @board_stats_grid = initialize_grid(*grid_builder.args)
      @current_grid = grid_builder.query_type
      render template: "client_admin/show"
    end
  end

  private

    def user_onboarding_params
      params.require(:user_onboarding).permit(:email, :onboarding_id, :name)
    end

    def should_onboard?
      @user = User.where(email: params[:user_onboarding][:email]).first_or_initialize
      @user.user_onboarding.nil?
    end

    def set_auth_cookie
      cookie[:user_onboarding]="12345"
    end
end
