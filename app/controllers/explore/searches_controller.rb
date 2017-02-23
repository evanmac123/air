class Explore::SearchesController < ExploreBaseController
  layout 'search_layout'

  def show
    @search_service = AirboSearch.new(params[:query], current_user)

    if request.xhr? && params[:section]
      partial = params[:tilesContainer] || 'shared/tiles/contextual_tiles'

      content = render_to_string(
                  partial: partial,
                  locals: { tiles: tiles_to_render, presenter: presenter_to_render })

      render json: {
        success:   true,
        content:   content,
        added:     tiles_to_render.count,
        lastBatch: last_batch?,
        page: params[:page]
      }
    else
      @search_service.track_initial_search
    end
  end

  private

    def search_section
      case params[:section]
      when "client_admin_tiles"
        { tiles_to_render: "client_admin_tiles", presenter_to_render: SingleAdminTilePresenter }
      when "explore_tiles"
        { tiles_to_render: "explore_tiles", presenter_to_render: SingleExploreTilePresenter }
      when "user_tiles"
        { tiles_to_render: "user_tiles", presenter_to_render: SingleTilePresenter }
      end
    end

    def tiles_to_render
      @search_service.send(search_section[:tiles_to_render], params[:page])
    end

    def presenter_to_render
      search_section[:presenter_to_render]
    end

    def last_batch?
      params[:count].to_i + tiles_to_render.count == tiles_to_render.total_count
    end
end
