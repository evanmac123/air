class UserOnboardingsController < ApplicationController
  skip_before_filter :authorize, only: [:show]
  skip_before_filter :authorize_with_onboarding_auth_hash
  layout 'onboarding'

  def show
    @user_onboarding = UserOnboarding.includes([:user, :onboarding]).find(params[:id])
    @board = @user_onboarding.board
    sign_in(@user_onboarding.user)

    @tiles = Tile.displayable_categorized_to_user(current_user, nil)
  end

  def create
    #create actions for secondary users
  end

  def activity
    @user_onboarding = UserOnboarding.includes([:user, :onboarding]).find(params[:id])
    if request.user_agent =~ /Mobile|webOS/
      render template: "user_onboardings/activity_mobile"
    else
      #create poro to manage actiivty
      @board = @user_onboarding.board
      @chart_form = BoardStatsLineChartForm.new @board, {action_type: params[:action_type]}
      @chart = BoardStatsChart.new(@chart_form.period, @chart_form.plot_data, "#fff").draw

      grid_builder = BoardStatsGrid.new(@board)
      @board_stats_grid = initialize_grid(*grid_builder.args)
      @current_grid = grid_builder.query_type
      render template: "client_admin/show"
    end
  end

  private
  def user_onboarding_params
    {
      id: params[:id],
      topic_board_id: params[:topic_board_id]
    }
  end
end
