# frozen_string_literal: true

class ExploreController < ExploreBaseController
  include ExploreConcern

  before_action :set_initial_objects
  before_action :schedule_explore_pings

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

  private

    def schedule_explore_pings
      if params[:email_type].present?
        explore_email_clicked_ping(
          user: current_user,
          email_type: params[:email_type],
          email_version: params[:email_version]
        )
      end
    end

    def set_initial_objects
      unless request.xhr?
        set_intro_slides
        @tile_features = TileFeature.ordered
        @related_campaigns = Campaign.order(updated_at: :desc)
      end
    end

    def set_intro_slides
      if show_slides? && params[:requested_tile_id].nil?
        cookies[:airbo_explore] = Time.current
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
