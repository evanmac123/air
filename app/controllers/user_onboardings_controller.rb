class UserOnboardingsController < ApplicationController
  skip_before_filter :authorize, only: [:show]
  layout 'onboarding'

  def show
    @user_onboarding = UserOnboarding.includes([:user, :onboarding]).find(params[:id])
    @board = @user_onboarding.board
    sign_in(@user_onboarding.user)
    @tiles = Tile.displayable_categorized_to_user(current_user, 10)
  end

  def activity
    @user_onboarding = UserOnboarding.includes([:user, :onboarding]).find(params[:id])
    if request.user_agent =~ /Mobile|webOS/
      render template: "user_onboardings/activity_mobile"
    else
      @board = @user_onboarding.board
      @chart_form = BoardStatsLineChartForm.new @board, {action_type: params[:action_type]}
      @chart = BoardStatsChart.new(@chart_form.period, @chart_form.plot_data, "#fff").draw

      grid_builder = BoardStatsGrid.new(@board)
      @board_stats_grid = initialize_grid(*grid_builder.args)
      @current_grid = grid_builder.query_type
      render template: "client_admin/show"
    end
  end

  def share
    @user_onboarding = UserOnboarding.includes([:user, :onboarding]).find(params[:id])
  end

  def create
    @user_onboarding = UserOnboarding.find(params[:id])
    UserOnboardingInitializer.new(@user_onboarding, params[:user_onboardings]).save

    @user_onboarding.update_state
    redirect_to myairbo_path(@user_onboarding, { shared: true, state: @user_onboarding.state })
  end

  private
    def user_onboarding_params
      {
        id: params[:id],
        topic_board_id: params[:topic_board_id]
      }
    end
end
