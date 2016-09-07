class ClientAdmin::BoardStatsGridsController < ClientAdminBaseController
  def index
    @tile = Tile.first
    grid_builder = BoardStatsGrid.new(@tile, params["grid_type"], params[:answer_filter])
    @board_stats_grid = initialize_grid(*grid_builder.args)
    @current_grid = grid_builder.query_type

    export_grid_if_requested('board_stats_grid' => 'grid') do
      render json: { grid: grid_to_string, success: true }
    end
  end

  def new_completions_count
    tile = Tile.first
    start_time = Time.at params[:start_time_in_ms].to_i/1000
    count = tile.tile_completions.where{created_at >= start_time }.count
    text = count > 0 ? "Load #{count} new event".pluralize(count) : ""
    render json: { text: text }
  end

  protected
    def grid_to_string
      render_to_string(
        partial: 'client_admin/activity/activity_grid_section',
        formats: [:html]
      )
    end
end
