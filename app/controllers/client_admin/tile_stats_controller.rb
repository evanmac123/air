class ClientAdmin::TileStatsController < ClientAdminBaseController
  def index
    @tile = Tile.find(params[:tile_id])

    @chart_form = TileStatsChartForm.new @tile, {action_type: params[:action_type]}

    @survey_chart = @tile.survey_chart if @tile.is_survey?

    respond_to do |format|
      format.html
      format.json do
        render json: { page: page_to_string }
      end
    end
  end

  protected
    def page_to_string
      render_to_string(
        'index',
        formats: [:html],
        layout: false
      )
    end
end
