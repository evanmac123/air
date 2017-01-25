class ExploreController < ExploreBaseController
  before_filter :set_intro_slides

  def show
    @tiles = Tile.explore_without_featured_tiles.page(params[:page]).per(28)

    if request.xhr?
      content = render_to_string(
                  partial: "explore/tiles",
                  locals: { tiles: @tiles, section: "Explore" })

      render json: {
        success:   true,
        content:   content,
        added:     @tiles.count,
        lastBatch: params[:count] == @tiles.total_count.to_s
      }
    end
  end

  def search
    render text: 'hi'
  end

  private

    def set_intro_slides
      if show_slides?
        cookies[:airbo_explore] = Time.now
        @show_explore_onboarding = true
      end
    end

    def show_slides?
      if current_user.is_a?(User)
        params[:show_explore_onboarding]
      else
        !cookies[:airbo_explore]
      end
    end
end
